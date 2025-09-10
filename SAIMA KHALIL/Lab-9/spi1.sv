module spi1 #(
    parameter int NUM_SLAVES = 4,
    parameter int DATA_WIDTH = 8
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [DATA_WIDTH-1:0]     tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                      start_transfer,
    input  logic                      cpol,
    input  logic                      cpha,
    input  logic [15:0]               clk_div,

    output logic [DATA_WIDTH-1:0]     rx_data,
    output logic                      transfer_done,
    output logic                      busy,

    output logic                      spi_clk,
    output logic                      spi_mosi,
    input  logic                      spi_miso,
    output logic [NUM_SLAVES-1:0]     spi_cs_n
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSFER,
        DONE
    } state_t;

    state_t cstate, nstate;

    logic [DATA_WIDTH-1:0] shift_reg_tx, shift_reg_rx;
    logic [4:0] bit_cnt;
    logic [15:0] clk_cnt;
    logic spi_clk_int;
    logic spi_clk_en;
    logic [$clog2(NUM_SLAVES)-1:0] sel_reg;

    // Edge detection signals
    logic spi_clk_prev;
    logic rising_edge_sck, falling_edge_sck;
    logic leading_edge, trailing_edge;
    logic sample_edge, shift_edge;

  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cstate        <= IDLE;
            shift_reg_tx  <= 0;
            shift_reg_rx  <= 0;
            bit_cnt       <= 0;
            clk_cnt       <= 0;
            spi_clk_int   <= cpol;
            sel_reg       <= 0;
            spi_clk_prev  <= cpol;
            rx_data       <= 0;
        end else begin
            cstate <= nstate;
            spi_clk_prev <= spi_clk_int;  // store previous for edge detection

            // Clock divider
            if (spi_clk_en) begin
                if (clk_cnt == clk_div) begin
                    clk_cnt <= 0;
                    spi_clk_int <= ~spi_clk_int;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end else begin
                clk_cnt <= 0;
                spi_clk_int <= cpol;
            end

            // State operations
            case(cstate)
                IDLE: begin
                    if (start_transfer)
                        sel_reg <= slave_sel;
                end

                LOAD: begin
                    shift_reg_tx <= tx_data;
                    shift_reg_rx <= 0;
                    bit_cnt      <= 0;
                end

                TRANSFER: begin
                    // Shift MOSI
                    if (shift_edge)
                        shift_reg_tx <= {shift_reg_tx[DATA_WIDTH-2:0], 1'b0};

                    // Sample MISO
                    if (sample_edge) begin
                        shift_reg_rx <= {shift_reg_rx[DATA_WIDTH-2:0], spi_miso};
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                DONE: begin
                    rx_data <= shift_reg_rx;
                end
            endcase
        end
    end
 
    assign rising_edge_sck  = (spi_clk_prev == 1'b0) && (spi_clk_int == 1'b1);
    assign falling_edge_sck = (spi_clk_prev == 1'b1) && (spi_clk_int == 1'b0);

    // Leading/trailing edges based on CPOL
    assign leading_edge  = (cpol == 0) ? rising_edge_sck : falling_edge_sck;
    assign trailing_edge = (cpol == 0) ? falling_edge_sck : rising_edge_sck;

    // Determine sample and shift edges based on CPHA
    assign sample_edge = (cpha == 1'b0) ? leading_edge  : trailing_edge;
    assign shift_edge  = (cpha == 1'b0) ? trailing_edge : leading_edge;

    // SPI outputs
    assign spi_clk  = spi_clk_int;
    assign spi_mosi = shift_reg_tx[DATA_WIDTH-1];

     
    always_comb begin
        nstate = cstate;
        case(cstate)
            IDLE:     if (start_transfer) nstate = LOAD;
            LOAD:     nstate = TRANSFER;
            TRANSFER: if (bit_cnt == DATA_WIDTH) nstate = DONE;
            DONE:     nstate = IDLE;
        endcase
    end
 
    always_comb begin
        busy = (cstate != IDLE);
        transfer_done = (cstate == DONE);
        spi_clk_en = (cstate == TRANSFER);

        spi_cs_n = {NUM_SLAVES{1'b1}};  // default inactive
        if (cstate == LOAD || cstate == TRANSFER)
            spi_cs_n[sel_reg] = 1'b0;   // select active slave
    end

endmodule 

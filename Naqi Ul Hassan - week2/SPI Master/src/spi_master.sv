module spi_master #(
    parameter int NUM_SLAVES  = 4,   // number of connected slaves
    parameter int DATA_WIDTH  = 8    // SPI data width
)(
    input  logic clk,                         // system clock
    input  logic rst_n,                       // active-low reset
    input  logic [DATA_WIDTH-1:0] tx_data,    // data to transmit
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel, // slave select input
    input  logic start_transfer,              // start signal
    input  logic cpol,                        // clock polarity
    input  logic cpha,                        // clock phase
    input  logic [15:0] clk_div,              // clock divider

    output logic [DATA_WIDTH-1:0] rx_data,    // received data
    output logic transfer_done,               // transfer completion flag
    output logic busy,                        // SPI busy flag

    // SPI interface
    output logic spi_clk,
    output logic spi_mosi,
    input  logic spi_miso,
    output logic [NUM_SLAVES-1:0] spi_cs_n
);

    // SPI state machine definition
    typedef enum logic [1:0] { 
        IDLE, 
        SETUP, 
        TRANSFER, 
        COMPLETE 
    } spi_state;

    // internal signals
    logic                           spi_clk_n;
    logic [$clog2(DATA_WIDTH):0]    bit_count, bit_count_n;
    logic [$clog2(NUM_SLAVES)-1:0]  slave_sel_reg, slave_sel_reg_n;
    logic [DATA_WIDTH-1:0]          shift_reg_tx, shift_reg_tx_n;
    logic [DATA_WIDTH-1:0]          shift_reg_rx, shift_reg_rx_n;
    logic [15:0]                    clk_count, clk_count_n;
    logic                           drive_edge, drive_edge_n;
    logic                           sample_edge, sample_edge_n;
    logic                           cpha_reg, cpha_reg_n;
    logic                           cpol_reg, cpol_reg_n;
    logic [15:0]                    clk_div_reg, clk_div_reg_n;

    spi_state curr_state, next_state;

    // state register
    always_ff @(posedge clk) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // next state logic
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE:     next_state = (start_transfer) ? SETUP : IDLE;
            SETUP:    next_state = TRANSFER;
            TRANSFER: next_state = (bit_count == DATA_WIDTH) ? COMPLETE : TRANSFER;
            COMPLETE: next_state = IDLE;
        endcase
    end

    // combinational logic
    always_comb begin
        // default assignments
        slave_sel_reg_n = slave_sel_reg;
        shift_reg_rx_n  = shift_reg_rx;
        sample_edge_n   = sample_edge;
        drive_edge_n    = drive_edge;
        cpha_reg_n      = cpha_reg;
        cpol_reg_n      = cpol_reg;
        shift_reg_tx_n  = shift_reg_tx;
        clk_div_reg_n   = clk_div_reg;
        spi_clk_n       = spi_clk;
        bit_count_n     = bit_count;
        clk_count_n     = clk_count;

        spi_cs_n        = '1;    // all slaves deselected
        transfer_done   = 1'b0;

        case (curr_state)
            // idle: wait for start
            IDLE: begin
                busy            = 1'b0;
                slave_sel_reg_n = slave_sel;
                cpha_reg_n      = cpha;
                cpol_reg_n      = cpol;
                shift_reg_tx_n  = tx_data;      // preload TX data
                clk_div_reg_n   = clk_div;
                spi_clk_n       = cpol;         // idle clock state
                sample_edge_n   = 0;
                drive_edge_n    = 0;
                bit_count_n     = 0;
                clk_count_n     = 0;
            end

            // setup: assert CS and get ready
            SETUP: begin
                spi_clk_n                = cpol_reg;
                busy                     = 1'b1;
                spi_cs_n[slave_sel_reg]  = 1'b0; // enable selected slave
            end

            // transfer: shift data
            TRANSFER: begin
                busy                    = 1'b1;
                spi_cs_n[slave_sel_reg] = 1'b0;

                // clock generation based on CPOL/CPHA
                case ({cpol_reg, cpha_reg})
                    2'b00: spi_clk_n = (clk_count < (clk_div_reg >> 1)) ? 1'b1 : 1'b0;
                    2'b01: spi_clk_n = (clk_count < (clk_div_reg >> 1)) ? 1'b0 : 1'b1;
                    2'b10: spi_clk_n = (clk_count < (clk_div_reg >> 1)) ? 1'b0 : 1'b1;
                    2'b11: spi_clk_n = (clk_count < (clk_div_reg >> 1)) ? 1'b1 : 1'b0;
                    default: spi_clk_n = cpol_reg;
                endcase

                clk_count_n  = (clk_count == clk_div_reg) ? 0 : clk_count + 1;
                bit_count_n  = (sample_edge) ? bit_count + 1 : bit_count;

                // detect edges
                drive_edge_n = (clk_count == 0) ? 1'b1 : 1'b0;
                sample_edge_n= (clk_count == (clk_div_reg >> 1)) ? 1'b1 : 1'b0;

                // shift out MOSI on drive edge
                shift_reg_tx_n = (drive_edge) ? {shift_reg_tx[DATA_WIDTH-2:0], 1'b0} : shift_reg_tx;

                // shift in MISO on sample edge
                shift_reg_rx_n = (sample_edge) ? {shift_reg_rx[DATA_WIDTH-2:0], spi_miso} : shift_reg_rx;
            end

            // complete: latch data, keep CS low until end
            COMPLETE: begin
                transfer_done            = 1'b1;
                busy                     = 1'b1;
                spi_clk_n                = cpol_reg;
                spi_cs_n[slave_sel_reg]  = 1'b0;
            end
        endcase
    end

    // sequential registers
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            slave_sel_reg <= 0;
            cpha_reg      <= 0;
            cpol_reg      <= 0;
            shift_reg_tx  <= 0;
            shift_reg_rx  <= 0;
            clk_div_reg   <= 0;
            sample_edge   <= 0;
            drive_edge    <= 0;
        end else begin
            slave_sel_reg <= slave_sel_reg_n;
            sample_edge   <= sample_edge_n;
            drive_edge    <= drive_edge_n;
            cpha_reg      <= cpha_reg_n;
            cpol_reg      <= cpol_reg_n;
            shift_reg_tx  <= shift_reg_tx_n;
            shift_reg_rx  <= shift_reg_rx_n;
            clk_div_reg   <= clk_div_reg_n;
        end
    end

    // bit counter
    always_ff @(posedge clk) begin
        if (!rst_n)
            bit_count <= 0;
        else
            bit_count <= bit_count_n;
    end

    // clock counter
    always_ff @(posedge clk) begin
        if (!rst_n)
            clk_count <= 0;
        else
            clk_count <= clk_count_n;
    end

    // send data on MOSI
    always_ff @(posedge drive_edge)
        spi_mosi <= shift_reg_tx[DATA_WIDTH-1];

    // update spi_clk
    always_ff @(posedge clk) begin
        if (!rst_n)
            spi_clk <= 0;
        else
            spi_clk <= spi_clk_n;
    end

    // received data output
    assign rx_data = shift_reg_rx;

endmodule

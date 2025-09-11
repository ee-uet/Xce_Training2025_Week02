module spi_master #(
    parameter int NUM_SLAVES  = 4,
    parameter int DATA_WIDTH  = 8
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic [DATA_WIDTH-1:0]    tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                     start_transfer,
    input  logic                     cpol,
    input  logic                     cpha,
    input  logic [15:0]              clk_div,

    output logic [DATA_WIDTH-1:0]    rx_data,
    output logic                     transfer_done,
    output logic                     busy,

    // SPI interface
    output logic                     spi_clk,
    output logic                     spi_mosi,
    input  logic                     spi_miso,
    output logic [NUM_SLAVES-1:0]    spi_cs_n
);

    // ------------------------
    // FSM States
    // ------------------------
    typedef enum logic [1:0] { 
        IDLE,
        START,
        TRANSFER,
        STOP
    } state_t; 

    state_t current_state, next_state; 

    // ------------------------
    // Internal signals
    // ------------------------
    logic [16:0]                      count;
    logic [DATA_WIDTH-1:0]            tx_shifter;
    logic [DATA_WIDTH-1:0]            rx_shifter;
    logic [$clog2(DATA_WIDTH):0]      bit_count;

    logic                             clk_en;
    logic                             spi_clk_internal, spi_clk_dly;
    logic                             rising_edge, falling_edge;
    logic                             setup_tick, sample_tick;
    logic                             load_shifter, shift_en;
    logic                             bit_counter_done;

// FSM sequential
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// FSM combinational (includes CPOL/CPHA decode)
always_comb begin
    // Defaults
    next_state    = current_state;
    busy          = 1'b1;
    transfer_done = 1'b0;
    spi_cs_n      = {NUM_SLAVES{1'b1}};
    load_shifter  = 1'b0;
    shift_en      = 1'b0;
    clk_en        = 1'b1;
    sample_tick   = 0;
    setup_tick    = 0;

    // decoder logic for all modes
    unique case ({cpol,cpha})
        2'b00: begin sample_tick = rising_edge;  setup_tick = falling_edge; end // Mode 0
        2'b01: begin sample_tick = falling_edge; setup_tick = rising_edge;  end // Mode 1
        2'b10: begin sample_tick = rising_edge;  setup_tick = falling_edge;  end // Mode 2
        2'b11: begin sample_tick = falling_edge; setup_tick = rising_edge; end // Mode 3
    endcase

    case (current_state)
        IDLE: begin
            busy = 1'b0;
            if (start_transfer) begin
                next_state = START;
            end
            else begin
                next_state = IDLE;
            end
        end


        START: begin
            load_shifter        = 1'b1;
            spi_cs_n[slave_sel] = 1'b0;
            next_state          = TRANSFER;
        end


        TRANSFER: begin
            spi_cs_n[slave_sel] = 1'b0;
            //clk_en              = 1'b1;
            shift_en            = 1'b1;
            if (bit_counter_done)
                next_state = STOP;
        end


        STOP: begin
            transfer_done = 1'b1;
            next_state    = IDLE;
        end
    endcase
end

// 3. SPI clock gen + divider + edge detect 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count            <= 0;
        spi_clk_internal <= cpol;
        spi_clk_dly      <= cpol;
    end 
    else begin
        if (clk_en) begin
            if (count >= clk_div) begin
                count            <= 0;
                spi_clk_internal <= ~spi_clk_internal;
            end else
                count <= count + 1;
        end 
        else begin
            count            <= 0;
            spi_clk_internal <= cpol;
        end
        spi_clk_dly <= spi_clk_internal; // delay register
    end
end

assign rising_edge  =  spi_clk_internal & ~spi_clk_dly;
assign falling_edge = ~spi_clk_internal &  spi_clk_dly;
assign spi_clk      =  spi_clk_internal;


// 4. Separate Shift Logic for TX and RX
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_shifter <= '0;
        rx_shifter <= '0;
        bit_count  <= '0;
    end else begin
        if (load_shifter) begin
            tx_shifter <= tx_data;
            // ** FIX 1: Load counter with an extra count to provide a delay cycle **
            bit_count  <= DATA_WIDTH + 1;
        end
        // TX shifter updates on setup_tick to prepare MOSI for the slave
        else if (shift_en && setup_tick) begin
            tx_shifter <= {tx_shifter[DATA_WIDTH-2:0], 1'b0};
        end
        
        // RX shifter updates on sample_tick to capture MISO.
        // Counter is also decremented here to keep it synchronized.
        if (shift_en && sample_tick) begin
            rx_shifter <= {rx_shifter[DATA_WIDTH-2:0], spi_miso};
            bit_count  <= bit_count - 1;
        end
		if (!shift_en) begin
			rx_shifter <= 8'b0;
		end
    end
end


//-----out
assign spi_mosi         = tx_shifter[DATA_WIDTH-1];
assign rx_data          = rx_shifter;
// ** FIX 2: Change condition to 1 to match new counter logic **
assign bit_counter_done = (bit_count == 1);


endmodule


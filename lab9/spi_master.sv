import pkg::*;
module spi_master #(
parameter int NUM_SLAVES = 4,
parameter int DATA_WIDTH = 8
)(
input logic clk,
input logic rst_n,
input logic [DATA_WIDTH-1:0] tx_data,
input logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
input logic start_transfer,
input logic cpol,
input logic cpha,
input logic [15:0] clk_div,
output logic [DATA_WIDTH-1:0] rx_data,
output logic transfer_done,
output logic busy,
// SPI interface
output logic spi_clk,
output logic spi_mosi,
input logic spi_miso,
output logic [NUM_SLAVES-1:0] spi_cs_n
);
// TOD: Implement SPI master
logic [$clog2(NUM_SLAVES)-1:0]slave_sel_reg;
spi_state curr_state,next_state;

always_ff @( posedge clk ) begin : blockName
    if (!rst_n) begin
        curr_state<=IDEAL;
        slave_sel_reg <= '0;
    end else begin
        curr_state<=next_state;
        if (curr_state==IDEAL) begin
            slave_sel_reg <=slave_sel;
        end
        
    end
end

always_comb begin
    next_state = curr_state;
    spi_cs_n = '1; // All CS_N high by default
    busy = 1'b0;
    transfer_done = 1'b0;
    case (curr_state)
        IDLE: begin
            if (start_transfer)
                next_state = SETUP;
        end
        SETUP: begin
            next_state = TRANSFER;
        end
        TRANSFER: begin
            if ( bit_count == DATA_WIDTH - 1)
                next_state = COMPLETE;
        end
        COMPLETE: begin
            if (!start_transfer)
                next_state = IDLE;
        end
    endcase
    end


always_comb begin
    shift_reg_tx = '0;
    shift_reg_rx = '0;
    spi_mosi     = 1'b0;
    rx_data      = '0;
    case (curr_state)
        IDLE: begin
            shift_reg_tx  = tx_data; // Load transmit data
        end
        SETUP: begin
            busy = 1'b1;
            spi_cs_n[slave_sel_reg] = 1'b0; 
            // Drive first bit if CPHA = 0
            if (cpha == 1'b0)
                spi_mosi = shift_reg_tx[DATA_WIDTH-1];
        end
        TRANSFER: begin
            busy = 1'b1;
            spi_cs_n[slave_sel_reg] = 1'b0; 
            if (drive_edge) begin
                // Shift out MOSI
                spi_mosi = shift_reg_tx[DATA_WIDTH-1];
                shift_reg_tx = {shift_reg_tx[DATA_WIDTH-2:0], 1'b0};
            end
            if (sample_edge) begin
                // Shift in MISO
                shift_reg_rx = {shift_reg_rx[DATA_WIDTH-2:0], spi_miso};
            end
        end
        COMPLETE: begin
            transfer_done = 1'b1;
            busy = 1'b1;
            spi_cs_n[slave_sel_reg] = 1'b0; 
            rx_data = shift_reg_rx; // Output received data
        end
    endcase
end

//receiving bit counter
logic [$clog2(DATA_WIDTH)-1:0]bit_count,bit_count_n;
always_comb begin 
    if ((curr_state==TRANSFER) && (sample_edge)) begin
        bit_count_n=bit_count+1;
    end else begin
        bit_count_n = bit_count;
    end
end

always_ff @( posedge clk ) begin : blockName
    if (!rst_n) begin
        bit_count=0;
    end else begin
        bit_count<=bit_count_n;
    end
end

//clk generation
logic spi_clk,spi_clk_n;
logic [15:0]clk_count,clk_count_n;
always_comb begin 
    clk_count_n=clk_count+1;
    if (clk_count==(clk_div-1)) begin
        spi_clk_n=~spi_clk;
        clk_count_n=0;
    end
    else begin
        spi_clk_n=spi_clk;
    end
end
always_ff @( posedge clock ) begin 
    if (!rst_n) begin
        spi_clk <=cpol;
        clk_count    <=0;
    end else if(curr_state==TRANSFER) begin
        spi_clk <=spi_clk_n;
        clk_count    <=clk_count_n;
    end
end
// Consider: How to handle different CPOL/CPHA modes?
    // Edge detection for sampling and driving
assign sample_edge = (cpol == cpha) ? ~sclk_internal : sclk_internal;
assign drive_edge  = (cpol == cpha) ? sclk_internal : ~sclk_internal;
endmodule
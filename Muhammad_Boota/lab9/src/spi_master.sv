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
logic [$clog2(DATA_WIDTH):0]bit_count,bit_count_n;
logic [$clog2(NUM_SLAVES)-1:0]slave_sel_reg;
logic [DATA_WIDTH-1:0]shift_reg_tx,shift_reg_rx;
logic [15:0]clk_count,clk_count_n;
logic drive_edge,sample_edge,cpha_reg,cpol_reg;
logic [15:0] clk_div_reg;
spi_state curr_state,next_state;

always_ff @( posedge clk ) begin : blockName
    if (!rst_n) begin
        curr_state<=IDLE;
    end else begin
        curr_state<=next_state;
    end
end

always_comb begin
    next_state = curr_state;
    case (curr_state)
        IDLE: begin
            if (start_transfer)
                next_state = SETUP;
            else 
                next_state = SETUP;
        end
        SETUP: begin
            next_state = TRANSFER;
        end
        TRANSFER: begin
            if ( bit_count == DATA_WIDTH)
                next_state = COMPLETE;
            else
                next_state = TRANSFER;
        end
        COMPLETE: begin
            next_state = IDLE;
        end
    endcase
    end


    always_comb begin
        spi_cs_n = '1; // All CS_N high by default
        transfer_done = 1'b0;
        rx_data =0;
        case (curr_state)
            SETUP: begin
                busy = 1'b1;
                spi_cs_n[slave_sel_reg] = 1'b0;
            end
            TRANSFER: begin
                busy = 1'b1;
                spi_cs_n[slave_sel_reg] = 1'b0;
            end
            COMPLETE: begin
                transfer_done = 1'b1;
                busy = 1'b0;
                spi_cs_n[slave_sel_reg] = 1'b0; 
                rx_data = shift_reg_rx; // Output received data
            end
        endcase
    end

always_ff @( posedge clk ) begin
    if (!rst_n) begin
        cpha_reg      <=0;
        cpol_reg      <=0;
        spi_clk       <=0;
        shift_reg_tx  <=0;
        clk_div_reg   <=0;
        spi_mosi      <=0;
        clk_count     <=0;
        bit_count     <=0;
        shift_reg_rx  <=0;
         slave_sel_reg<=0;
    end else begin
        case (curr_state)
            SETUP:begin
                slave_sel_reg <=slave_sel;
                cpha_reg      <=cpha;
                cpol_reg      <=cpol;
                shift_reg_tx  <= tx_data; // Load transmit data
                clk_div_reg   <= clk_div;
                spi_clk       <=cpha;
                bit_count     <=0;
                clk_count     <=0;
                end
            TRANSFER:begin
                clk_count    <=clk_count_n;
                if (drive_edge) begin
                    // Shift out MOSI
                    spi_mosi <= shift_reg_tx[DATA_WIDTH-1];
                    shift_reg_tx <= {shift_reg_tx[DATA_WIDTH-2:0], 1'b0};
                end
                if (sample_edge) begin
                    // Shift in MISO
                    shift_reg_rx <= {shift_reg_rx[DATA_WIDTH-2:0], spi_miso};
                    bit_count    <=bit_count_n;
                end

                if (clk_count==(clk_div_reg)) 
                    spi_clk <=~spi_clk;
            end
            default: begin end
        endcase
    end
end

//receiving bit counter
always_comb begin 
        bit_count_n=bit_count+1;
end

//clk generation

always_comb begin 
    if (clk_count==(clk_div_reg))
        clk_count_n=0;
    else 
        clk_count_n=clk_count+1;
end
// Consider: How to handle different CPOL/CPHA modes?
    // Edge detection for sampling and driving
always_comb begin 
    if (cpol_reg) begin
        sample_edge = (cpol_reg == cpha_reg) ? ~spi_clk  : spi_clk ;
        drive_edge  = (cpol_reg == cpha_reg) ? spi_clk  : ~spi_clk ;
    end else begin
        drive_edge   = (cpol_reg == cpha_reg) ? ~spi_clk  : spi_clk ;
        sample_edge  = (cpol_reg == cpha_reg) ? spi_clk  : ~spi_clk ;
    end
end 
endmodule
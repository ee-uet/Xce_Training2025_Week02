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
logic spi_clk_n;
logic [$clog2(DATA_WIDTH):0]bit_count,bit_count_n;
logic [$clog2(NUM_SLAVES)-1:0]slave_sel_reg,slave_sel_reg_n;
logic [DATA_WIDTH-1:0]shift_reg_tx,shift_reg_tx_n,shift_reg_rx,shift_reg_rx_n;
logic [15:0]clk_count,clk_count_n;
logic drive_edge,drive_edge_n,sample_edge,sample_edge_n,cpha_reg,cpha_reg_n,cpol_reg,cpol_reg_n;
logic [15:0] clk_div_reg,clk_div_reg_n;
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
                next_state = IDLE;
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
        slave_sel_reg_n =slave_sel_reg   ;
        shift_reg_rx_n  =shift_reg_rx    ;
        sample_edge_n   =sample_edge     ;
        drive_edge_n    =drive_edge      ;
        cpha_reg_n      =cpha_reg        ;
        cpol_reg_n      =cpol_reg        ;
        shift_reg_tx_n  =shift_reg_tx    ;
        clk_div_reg_n   =clk_div_reg     ;
        spi_clk_n       =spi_clk         ;
        bit_count_n     =bit_count       ;
        clk_count_n     =clk_count       ;
        spi_cs_n = '1; // All CS_N high by default
        transfer_done = 1'b0;
        case (curr_state)
            IDLE: begin
                busy = 1'b0;
                slave_sel_reg_n =slave_sel;
                cpha_reg_n      =cpha;
                cpol_reg_n      =cpol;
                shift_reg_tx_n  =tx_data; // Load transmit data
                clk_div_reg_n   =clk_div;
                spi_clk_n       =cpol; // Idle state of clock
                sample_edge_n   =0;
                drive_edge_n    =0;
                bit_count_n     =0;
                clk_count_n     =0;
            end
            SETUP: begin
                spi_clk_n       =cpol_reg;
                busy = 1'b1;
                spi_cs_n[slave_sel_reg] = 1'b0;
            end
            TRANSFER: begin
                busy = 1'b1;
                spi_cs_n[slave_sel_reg] = 1'b0;
                case ({cpol_reg,cpha_reg})
                    2'b00:spi_clk_n = (clk_count < (clk_div_reg>>1)) ? 1'b1 : 1'b0;
                    2'b01:spi_clk_n = (clk_count < (clk_div_reg>>1)) ? 1'b0 : 1'b1;
                    2'b10:spi_clk_n = (clk_count < (clk_div_reg>>1)) ? 1'b0 : 1'b1;
                    2'b11:spi_clk_n = (clk_count < (clk_div_reg>>1)) ? 1'b1 : 1'b0;
                    default: spi_clk_n = cpol_reg;
                endcase
                clk_count_n=(clk_count==(clk_div_reg)) ? 0 : clk_count+1;
                bit_count_n= (sample_edge) ? bit_count+1 : bit_count;
                // Consider: How to handle different CPOL/CPHA modes?
                // Edge detection for sampling and driving
                drive_edge_n = (clk_count == 0 ) ? 1'b1 : 1'b0;
                sample_edge_n= (clk_count == (clk_div_reg>>1) ) ? 1'b1 : 1'b0;
                // Shift out MOSI
                shift_reg_tx_n = (drive_edge) ? {shift_reg_tx[DATA_WIDTH-2:0], 1'b0} : shift_reg_tx;
                // Shift in MISO
                shift_reg_rx_n = (sample_edge) ? {shift_reg_rx[DATA_WIDTH-2:0], spi_miso}:shift_reg_rx;
                bit_count_n= (sample_edge) ? bit_count+1 : bit_count;
            end
            COMPLETE: begin
                transfer_done = 1'b1;
                busy = 1'b1;
                spi_clk_n=cpol_reg;
                spi_cs_n[slave_sel_reg] = 1'b0; 
            end
        endcase
    end

always_ff @(posedge clk) begin
        if (!rst_n) begin
            slave_sel_reg <=0;
            cpha_reg      <=0;
            cpol_reg      <=0;
            shift_reg_tx  <=0;
            sample_edge   <=0;
            drive_edge    <=0;
            shift_reg_rx  <=0;
            clk_div_reg   <=0;
        end else begin
            slave_sel_reg <=slave_sel_reg_n   ;
            sample_edge   <=sample_edge_n     ;
            drive_edge    <=drive_edge_n      ;
            cpha_reg      <=cpha_reg_n        ;
            cpol_reg      <=cpol_reg_n        ;
            shift_reg_tx  <=shift_reg_tx_n    ;
            shift_reg_rx  <=shift_reg_rx_n    ;
            clk_div_reg   <=clk_div_reg_n     ;
        end
end

//receiving bit counter
always_ff @(posedge clk) begin 
        if (!rst_n)
            bit_count <=0;
        else 
            bit_count <= bit_count_n; 
end

//clk generation
always_ff @( posedge clk ) begin 
    if (!rst_n)
        clk_count <=0;
    else 
        clk_count <= clk_count_n; 
    
end
//seding data
always_ff @( posedge drive_edge ) begin 
    spi_mosi <= shift_reg_tx[DATA_WIDTH-1];
end

always_ff @( posedge clk ) begin 
    if (!rst_n) begin
        spi_clk=0;
    end else begin
        spi_clk=spi_clk_n;
    end
end 
assign rx_data = shift_reg_rx;
endmodule
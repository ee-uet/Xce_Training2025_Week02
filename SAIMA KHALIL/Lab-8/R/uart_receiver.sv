module uart_receiver #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200,
    parameter FIFO_DEPTH = 8
)(
    input  logic       clk,        // system clock
    input  logic       rst,      // active low reset
    input  logic       rx_serial,  // incoming serial line
    input  logic       rx_ready,    // processor read request

    output logic [7:0] rx_data,    // received data byte
    output logic       rx_valid,   // data available
    output logic       frame_error, // framing error detect
    output logic baud_clk
);

    // Internal signals
    logic baud16_clk;
    logic s_empty, done_shifting;
    logic [7:0] shift_data_out;
    logic last_bit;
    logic [8:0] f_in;   // 8-bit data + frame_error
    logic [8:0] f_out;
    logic f_full, f_empty;
    logic f_wr_en;
 
    baud16 u_baud16 (
        .clk(clk),
        .reset(rst),
        .baud_clk16(baud16_clk)
    );

     baud inst_baud (
        .clk     (clk), 
        .rst   (rst),
        .baud_clk(baud_clk)
    );
   
    shiftregister u_shiftreg (
        .baud16(baud16_clk),
        .reset(rst),
        .serial_input(rx_serial),
        .s_empty(s_empty),
        .last_bit(last_bit),
        .done_shifting(done_shifting),
        .s_data_out(shift_data_out)
    );

 
    controller u_ctrl (
        .clk(baud_clk),
        .rst(rst),
        .rx_ready(rx_ready),       
        .f_empty(f_empty),
        .f_full(f_full),
        .done_shifting(done_shifting),
        .rx_valid(rx_valid)       // tells processor data is valid
    );

  
    fifo u_fifo (
        .clk(baud_clk),
        .reset(rst),
        .wr_en(f_wr_en),
        .rd_en(f_rd_en),
        .data_in(f_in),
        .data_out(f_out),
        .full(f_full),
        .empty(f_empty)
    );

    assign rx_data     = f_out[7:0];
    assign frame_error = f_out[8];
    assign f_rd_en = rx_ready & rx_valid;
    
    assign f_in = {frame_error, shift_data_out};
    assign f_wr_en   = done_shifting & ~f_full;



endmodule


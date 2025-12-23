module uart_transmitter #(
parameter int CLK_FREQ = 50_000_000,
parameter int BAUD_RATE = 115200,
parameter int FIFO_DEPTH = 8,
parameter int PARITY=1 //even parity
)(
input logic clk,
input logic rst_n,
input logic [7:0] tx_data,
input logic tx_en,
input logic tx_valid,
output logic tx_ready,
output logic tx_serial,
output logic tx_busy
);
logic baud_en,baud_reg_en,shift_en,shift_reg_en,bit_count_reg_en,bit_count,fifo_rd_en,parity;
logic [7:0] data;
// TOD: Implement UART transmitter
counter #(CLK_FREQ/BAUD_RATE) Baud_Count (
    .counted(baud_en),.enable(baud_reg_en),.*
);
counter #(8) Bit_Count (
    .counted(bit_count),.enable(bit_count_reg_en),.*
);
Shift_Reg shift_reg(
    .*
);
fifo tx_fifo(
    .rx_data(tx_data),.rx_valid(tx_valid),.tx_data(data), .*
);
tx_controller tx_controller(
    .*
);
// Consider: Baud rate accuracy and jitter
assign parity = (PARITY) ? ~(^data) : ^data;
endmodule
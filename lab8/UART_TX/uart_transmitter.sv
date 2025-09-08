module uart_transmitter #(
parameter int CLK_FREQ = 50_000_000,
parameter int BAUD_RATE = 115200,
parameter int FIFO_DEPTH = 8
)(
input logic clk,
input logic rst_n,
input logic [7:0] tx_data,
input logic tx_valid,
output logic tx_ready,
output logic tx_serial,
output logic tx_busy
);
// TOD: Implement UART transmitter
counter baud_count #(CLK_FREQ/BAUD_RATE)(
    .counted(baud_en),.enable(baud_reg_en),.*
);
counter bit_count #(8)(
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
endmodule
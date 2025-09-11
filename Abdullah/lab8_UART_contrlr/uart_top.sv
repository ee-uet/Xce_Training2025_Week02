module uart_top #(
    parameter CLK_FREQ             = 50_000_000,
    parameter BAUD_RATE            = 115200,
    parameter DATA_BITS            = 8,
    parameter SAMPLES_PER_BIT      = 16,
    parameter FIFO_DEPTH           = 16,
    parameter ALMOST_FULL_THRESH   = 14,
    parameter ALMOST_EMPTY_THRESH  = 2
)(
    input  logic                   clk,
    input  logic                   rst,

    // Transmitter inputs
    input  logic                   tx_wr_en,
    input  logic [7:0]             tx_wr_data,

    // Receiver outputs
    output logic [DATA_BITS-1:0]   rx_data_out,
    output logic                   rx_data_valid,
    input  logic                   rx_rd_en,        // external read enable
    output logic                   rx_frame_error,

    // TX FIFO count for monitoring
    output logic [3:0]             tx_fifo_count
);

    // Internal TX→RX wire
    logic tx_to_rx;

    // UART Transmitter
    tx_top i_tx (
        .clk(clk),
        .rst(rst),
        .wr_en(tx_wr_en),
        .wr_data(tx_wr_data),
        .tx(tx_to_rx),
        .count(tx_fifo_count)
    );
    
    // UART Receiver
    uart_rx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .SAMPLES_PER_BIT(SAMPLES_PER_BIT),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    ) i_rx (
        .clk(clk),
        .rst(rst),
        .rxd(tx_to_rx),
        .rx_data(rx_data_out),
        .write(rx_data_valid),
        .rd_en(rx_rd_en),
        .frame_error(rx_frame_error)
    );

endmodule

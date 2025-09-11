module uart_rx_top #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                     clk,
    input  logic                     reset_n,

    // Host interface
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    output logic                     fifo_full,
    output logic                     fifo_almost_full,

    // Controller interface
    input  logic                     start_rx,     
    input  logic                     data_available,
    input  logic [9:0]               data_in,      // sampled window input

    // Status outputs
    output logic                     rx_ready,
    output logic                     rx_busy,
    output logic                     rx_done,
    output logic                     frame_error,
    output logic [DATA_WIDTH-1:0]    rx_data_out
);

    // internal wires
    logic [DATA_WIDTH-1:0] fifo_out;
    logic fifo_empty, fifo_almost_empty;
    logic fifo_rd_en;

    // FIFO instantiation
    uart_rx_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk          (clk),
        .reset_n      (reset_n),
        .wr_en        (wr_en),
        .wr_data      (rx_data_out),
        .rd_en        (fifo_rd_en),
        .rd_data      (fifo_out),
        .full         (fifo_full),
        .empty        (fifo_empty),
        .almost_full  (fifo_almost_full),
        .almost_empty (fifo_almost_empty)
    );

    // Controller instantiation – notice rx_data is now INPUT to controller
    uart_rx_controller #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_ctrl (
        .clk           (clk),
        .reset_n       (reset_n),
        .rx_valid      (start_rx),       // trigger
        .rx_ready      (rx_ready),
        .rx_busy       (rx_busy),
        .rx_done       (rx_done),
        .data_in       (data_in),
        .data_available(data_available),
        .frame_error   (frame_error),
        .rx_data       (rx_data_out)     // processed data out
    );

    // FIFO read enable logic
    assign fifo_rd_en = rx_ready & ~fifo_empty & start_rx;

endmodule


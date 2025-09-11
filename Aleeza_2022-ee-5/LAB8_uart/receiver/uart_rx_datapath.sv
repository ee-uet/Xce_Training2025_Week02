module uart_tx_datapath #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                     clk,
    input  logic                     reset_n,

    // FIFO write side
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    output logic                     full,
    output logic                     almost_full,

    // Controller interface (RX side)
    input  logic                     rx_valid,     // start TX
    output logic                     rx_ready,     // controller ready
    output logic                     rx_busy,
    output logic                     rx_done,
    input  logic [9:0]               data_in,      // incoming sample window
    output logic                     frame_error,
    output logic [7:0]               rx_data_out   // from controller
);

    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_out;
    logic                  fifo_rd_en;
    logic                  fifo_empty, fifo_almost_empty;
    logic [$clog2(FIFO_DEPTH):0] fifo_count;


    // Instantiate FIFO for TX
    uart_rx_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk          (clk),
        .reset_n      (reset_n),
        .wr_en        (wr_en),
        .wr_data      (rx_data_out),         // connect wr_data to FIFO's data input
        .rd_en        (fifo_rd_en),
        .rd_data      (fifo_out),
        .full         (full),
        .empty        (fifo_empty),
        .almost_full  (almost_full),
        .almost_empty (fifo_almost_empty),
        .count        (fifo_count)
    );


    // Controller (reusing RX controller ports)
    uart_rx_controller #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_tx_ctrl (
        .clk            (clk),
        .reset_n        (reset_n),
        .data_in        (data_in),       // 10-bit sampled window
        .rx_valid       (rx_valid),      // start TX
        .data_available (data_available),
        .rx_done        (rx_done),
        .rx_ready       (rx_ready),
        .rx_busy        (rx_busy),
        .frame_error    (frame_error),
        .rx_data        (rx_data_out)    // 8-bit parallel data
    );

    // FIFO read enable: when controller ready and valid
    assign fifo_rd_en = rx_ready & data_available & rx_valid;

endmodule


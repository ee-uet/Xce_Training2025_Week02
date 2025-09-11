module uart_tx_datapath #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                     clk,
    input  logic                     reset_n,

    // FIFO interface
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    output logic                     full,
    output logic                     almost_full,

    // Controller interface
    input  logic                     tx_valid,       // user says "start tx"
    output logic                     tx_ready,       // controller ready
    output logic                     tx_busy,
    output logic                     tx_done,
    input logic                      tx_serial

);

    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_out;
    logic                  fifo_rd_en;
    logic                  fifo_empty, fifo_almost_empty;
    logic [$clog2(FIFO_DEPTH):0] fifo_count;

    // Data availability for controller
    logic data_available;

    // Instantiate FIFO for TX
    uart_tx_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk          (clk),
        .reset_n        (reset_n),
        .wr_en        (wr_en),
        .wr_data      (wr_data),
        .rd_en        (fifo_rd_en),
        .data         (fifo_out),
        .full         (full),
        .empty        (fifo_empty),
        .almost_full  (almost_full),
        .almost_empty (fifo_almost_empty),
        .count        (fifo_count)
    );

    // Controller for TX
    uart_tx_controller #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_tx_ctrl (
        .clk          (clk),
        .reset_n        (reset_n),
        .tx_data      (fifo_out),
        .data_available (data_available),
        .tx_valid     (tx_valid),
        .tx_done      (tx_done),
        .tx_ready     (tx_ready),
        .tx_serial    (tx_serial),
        .tx_busy      (tx_busy),
        .frame_error  (frame_error)
    );

    // FIFO read enable when controller ready to take new data
    assign fifo_rd_en = tx_ready & data_available & tx_valid;
endmodule


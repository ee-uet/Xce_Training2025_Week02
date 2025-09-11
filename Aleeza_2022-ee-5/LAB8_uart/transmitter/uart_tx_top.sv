module uart_tx_top #(
    parameter int FIFO_DEPTH = 16
)(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        wr_en,
    input  logic [7:0]  wr_data,
    input logic         data_available,
    input logic         tx_valid,
    output logic        tx_serial,
    output logic        tx_busy,
    output logic        tx_done,
    output logic        frame_error
);


    // FIFO <-> Controller
    logic [7:0] fifo_data_out;
    logic fifo_empty, fifo_full, fifo_rd_en;

    // Controller <-> Datapath
    logic [7:0] tx_data;
    logic  tx_ready;

    // FIFO instance
    uart_tx_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) tx_fifo_inst (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(fifo_rd_en),
        .data(fifo_data_out),
        .full(fifo_full),
        .empty(fifo_empty),
        .almost_full(),
        .almost_empty(),
        .count()
    );

    // Controller instance
    uart_tx_controller #(
        .FIFO_DEPTH(FIFO_DEPTH)
    ) tx_ctrl_inst (
        .clk(clk),
        .reset_n(reset_n),
        .tx_data(fifo_data_out),
        .data_available(~fifo_empty),
        .tx_valid(1'b1),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy),
        .frame_error(frame_error)
    );

    // Datapath instance
    uart_tx_datapath tx_dp_inst (
        .clk(clk),
        .reset_n(reset_n),
        .tx_serial(tx_serial)
    );

    // FIFO read enable (when controller ready)
    assign fifo_rd_en = tx_ready & ~fifo_empty;

endmodule


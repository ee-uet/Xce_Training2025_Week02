module tx_top (
    input  logic        clk,
    input  logic        rst, wr_en,
    input  logic [7:0]  wr_data,
    output logic        tx,
	output logic [3:0] count
);

    // Internal signals
    logic tick_tx, tick_rx;
    logic rd_en;
    logic full, empty, almost_full, almost_empty;
    logic tx_start, load, tx_done, load_done, transmit_done;
    logic [7:0] rd_data;

    // Baud rate generator
    baud_rate baud (
        .clk(clk),
        .rst(rst),
        .tick_tx(tick_tx),
        .tick_rx(tick_rx)
    );
	
    // FIFO
    fifo tx_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
		.count(count)
    );

    // Controller
    controller control_unit (
        .clk(clk),
        .rst(rst),
        .tick_tx(tick_tx),
        .empty(empty),
        .load_done(load_done),
        .transmit_done(transmit_done),
        .tx_start(tx_start),
        .load(load),
        .tx_done(tx_done),
		.rd_en(rd_en)
    );

    // Datapath
    tx_datapath datapath (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .load(load),
        .tx_done(tx_done),
		.tick_tx(tick_tx),
        .data_in(rd_data),
        .tx(tx),
        .load_done(load_done),
        .transmit_done(transmit_done)
    );

endmodule

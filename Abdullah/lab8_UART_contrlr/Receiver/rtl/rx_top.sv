module uart_rx_top #(
    parameter CLK_FREQ             = 50_000_000, // 50 MHz
    parameter BAUD_RATE            = 115200,
    parameter DATA_BITS            = 8,
    parameter SAMPLES_PER_BIT      = 16,
    parameter FIFO_DEPTH           = 16,
    parameter ALMOST_FULL_THRESH   = 14,
    parameter ALMOST_EMPTY_THRESH  = 2
)(
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   rxd,

    // FIFO interface
    output logic [DATA_BITS-1:0]   rx_data,
    output logic                   write,     // high when FIFO not empty
    input  logic                   rd_en,          // external read enable

    // Error signals
    output logic                   frame_error,
	//parity  signal
	output logic parity_bit	
);

    // Internal signals
    logic tick_rx;
    logic tick_tx; // not used
    logic data_sample_tick;
    logic shift_en;
    logic data_valid_fsm;    // from FSM, signals full byte
    logic fifo_wr_en;
    logic fifo_full;
    logic fifo_empty;
  

    // Baud Rate Generator
    baud_rate i_baud_rate (
        .clk(clk),
        .rst(rst),
        .tick_tx(tick_tx),
        .tick_rx(tick_rx)
    );

    // FSM (Controller)
    rx_controller i_fsm (
        .clk(clk),
        .rst(rst),
        .rx(rxd),
        .tick_rx(tick_rx),
        .start_sample_tick(),    // not needed externally
        .data_sample_tick(data_sample_tick),
        .shift_en(shift_en),
        .frame_error(frame_error),
		.data_valid(data_valid_fsm),
		.write(write)
    );

    // Datapath
    rx_datapath i_datapath (
        .clk(clk),
        .rst(rst),
        .rx(rxd),
        .data_sample_tick(data_sample_tick),
        .shift_en(shift_en),
        .data_valid_fsm(data_valid_fsm), // handshake from FSM
        .data_out(rx_data),
		.parity_bit(parity_bit)
	);

    // FIFO
    rx_fifo i_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(write),
        .wr_data(rx_data),
        .rd_en(rd_en),
        .rd_data(data_out),
        .full(fifo_full),
        .empty(fifo_empty),
        .almost_full(),
        .almost_empty(),
        .count()
    );


endmodule

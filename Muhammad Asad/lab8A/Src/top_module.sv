/* Implementation of UART Transmitter */

module top_module #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 25_000_000
)(
    input   logic       clk,
    input   logic       rst_n,
    input   logic       tx_valid,
    input   logic [7:0] tx_data,
    output  logic       tx_serial,
    output  logic       tx_ready,
    output  logic       tx_busy
);

    // Internal signals
    logic div_clk;
    logic start_count;
    logic count_done;
    logic load;
    logic start_shift;
    logic start;

    // Clock generator instance
    clk_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) clk_generator_inst (
        .clk(clk),
        .rst_n(rst_n),
        .div_clk(div_clk)
    );

    // Counter instance
    counter counter_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .start_count(start_count),
        .count_done(count_done)
    );

    // UART TX FSM instance
    uart_tx_fsm uart_tx_fsm_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .count_done(count_done),
        .load(load),
        .start_shift(start_shift),
        .start_count(start_count),
        .start(start),
        .tx_ready(tx_ready),
        .tx_busy(tx_busy)
    );

    // Shift register instance
    shift_reg shift_reg_inst (
        .div_clk(div_clk),
        .tx_data(tx_data),
        .rst_n(rst_n),
        .load(load),
        .start_shift(start_shift),
        .start(start),
        .tx_serial(tx_serial)
    );

endmodule
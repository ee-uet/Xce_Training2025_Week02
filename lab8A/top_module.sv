/* Implementation of UART Transmitter */

module top_module (
    input   logic clk,
    input   logic rst_n,
    input   logic tx_valid,
    input   logic [7:0] tx_data,
    output  logic tx_serial,
    output  logic tx_ready,
    output  logic tx_busy
);

    logic div_clk;
    logic start_count;
    logic count_done;
    logic load;
    logic start_shift;
    logic start;

    clk_generator #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115200)
    ) clk_generator_inst (
        .clk(clk),
        .rst_n(rst_n),
        .div_clk(div_clk)
    );
    counter counter_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .start_count(start_count),
        .count_done(count_done)
    );
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
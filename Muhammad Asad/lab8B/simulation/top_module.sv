/* 
    Implementation of a UART Receiver with Frame Error Detection
*/

    module top_module #(
        parameter CLK_FREQ = 50_000_000,
        parameter BAUD_RATE = 25_000_000
    )(
        input logic         clk,
        input logic         rst_n,
        input logic         rx_serial,
        output logic [7:0]  rx_data,
        output logic        rx_ready,
        output logic        frame_error,
        output logic        rx_busy
    );
    logic div_clk;
    logic zero_detected;
    logic count_done;
    logic start_count;
    logic start_shift;
    logic start_check;
    // Clock Divider Instance
    clk_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) clk_generator_inst (
        .clk(clk),
        .rst_n(rst_n),
        .div_clk(div_clk)
    );
    bit_detector bit_detector_inst (
        .div_clk(div_clk),
        .rx_serial(rx_serial),
        .zero_detected(zero_detected),
        .rst_n(rst_n)
    );
    uart_rx_fsm uart_rx_fsm_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .zero_detected(zero_detected),
        .count_done(count_done),
        .start_check(start_check),
        .start_count(start_count),
        .start_shift(start_shift),
        .rx_ready(rx_ready),
        .rx_busy(rx_busy)
    );
    counter counter_inst(
        .div_clk(div_clk),
        .rst_n(rst_n),
        .start_count(start_count),
        .count_done(count_done)
    );
    shift_reg shift_reg_inst (
        .div_clk(div_clk),
        .rx_serial(rx_serial),
        .rst_n(rst_n),
        .start_shift(start_shift),
        .start_check(start_check),
        .rx_data(rx_data),
        .frame_error(frame_error)
    );


    endmodule
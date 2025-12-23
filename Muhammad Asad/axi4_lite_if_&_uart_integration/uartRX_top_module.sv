/* 
    Implementation of a UART Receiver with Frame Error Detection
*/

    module uartRX_top_module #(
        parameter CLK_FREQ = 50_000_000
        
    )(
        input logic            clk,
        input logic            rst_n,
        input logic            rx_serial,
        axi_uart_intf.uart_rx  uart_rx_port
        
    );
    logic div_clk;
    logic zero_detected;
    logic count_done;
    logic start_count;
    logic start_shift;
    logic start_check;
    // Clock Divider Instance
    rx_clk_generator #(
        .CLK_FREQ(CLK_FREQ)
    ) clk_generator_inst (
        .clk(clk),
        .rst_n(rst_n),
        .div_clk(div_clk),
        .baud_rate(uart_rx_port.rx_baud_rate)
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
        .rx_ready(uart_rx_port.rx_ready)
    );
    rx_counter counter_inst(
        .div_clk(div_clk),
        .rst_n(rst_n),
        .start_count(start_count),
        .count_done(count_done)
    );
    rx_shift_reg shift_reg_inst (
        .div_clk(div_clk),
        .rx_serial(rx_serial),
        .rst_n(rst_n),
        .start_shift(start_shift),
        .start_check(start_check),
        .rx_data(uart_rx_port.rx_data),
        .frame_error(uart_rx_port.frame_error)
    );


    endmodule
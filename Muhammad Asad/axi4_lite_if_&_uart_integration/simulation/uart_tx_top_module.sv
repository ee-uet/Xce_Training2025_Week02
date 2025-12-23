/* Implementation of UART Transmitter */

module uart_tx_top_module #(
    parameter CLK_FREQ = 50_000_000
    
)(
    input   logic          clk,      
    input   logic          rst_n,    
    output  logic          tx_serial,
    axi_uart_intf.uart_tx  uart_tx_port
);
    
    // Internal signals
    logic div_clk;
    logic start_count;
    logic count_done;
    logic load;
    logic start_shift;
    logic start;

    // Clock generator instance
    rx_clk_generator #(
        .CLK_FREQ(CLK_FREQ)
        
    ) clk_generator_inst (
        .clk(clk),
        .rst_n(rst_n),
        .baud_rate(uart_tx_port.tx_baud_rate),
        .div_clk(div_clk)
    );

    // Counter instance
    tx_counter tx_counter_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .start_count(start_count),
        .count_done(count_done)
    );

    // UART TX FSM instance
    uart_tx_fsm uart_tx_fsm_inst (
        .div_clk(div_clk),
        .rst_n(rst_n),
        .tx_valid(uart_tx_port.tx_valid),
        .count_done(count_done),
        .load(load),
        .start_shift(start_shift),
        .start_count(start_count),
        .start(start),
        .tx_ready(uart_tx_port.tx_ready),
        .tx_ack(uart_tx_port.tx_ack)
        
    );

    // Shift register instance
    tx_shift_reg tx_shift_reg_inst (
        .div_clk(div_clk),
        .tx_data(uart_tx_port.tx_data),
        .rst_n(rst_n),
        .load(load),
        .start_shift(start_shift),
        .start(start),
        .tx_serial(tx_serial)
    );

endmodule
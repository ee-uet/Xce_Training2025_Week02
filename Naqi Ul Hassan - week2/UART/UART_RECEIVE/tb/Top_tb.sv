`timescale 1ns/1ps

module Top_tb;
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_RATE = 25_000_000;

    logic        clk;
    logic        rst_n;
    logic        rx_serial;
    logic [7:0]  rx_data;
    logic        rx_ready;
    logic        frame_error;
    logic        rx_busy;

    logic div_clk;

    // Clock Generator for div_clk
    ClkGenUART #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE)
    ) clk_gen (
        .clk        (clk),
        .rst_n      (rst_n),
        .div_clk    (div_clk)
    );

    // UART RX DUT
    Top #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE)
    ) uart_rx (
        .clk        (clk),
        .rst_n      (rst_n),
        .rx_serial  (rx_serial),
        .rx_data    (rx_data),
        .frame_error(frame_error),
        .rx_ready   (rx_ready),
        .rx_busy    (rx_busy)
    );

    // System clock generation
    initial clk = 0;
    always #10 clk = ~clk; // 50 MHz clock

    // Task to send a byte over RX line (LSB first)
    task send_byte(input [7:0] data_byte);
        integer i;
        begin
            // Start bit
            rx_serial = 0;
            @(posedge div_clk);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data_byte[i];
                @(posedge div_clk);
            end

            // Stop bit
            rx_serial = 1;
            @(posedge div_clk);

            // Return to idle
            repeat (2) @(posedge div_clk);
        end
    endtask

    initial begin
        // Reset
        rst_n = 0;
        rx_serial = 1; // idle state
        #25;
        rst_n = 1;
        @(posedge div_clk);

        // Send byte 10100101
        send_byte(8'b10100101);

        // Wait a few cycles to see outputs
        repeat (10) @(posedge div_clk);

        // Display results
        $display("RX Data = %b", rx_data);
        $display("RX Ready = %b", rx_ready);
        $display("Frame Error = %b", frame_error);
        $display("RX Busy = %b", rx_busy);

        $finish;
    end
endmodule

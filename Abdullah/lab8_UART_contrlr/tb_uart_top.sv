`timescale 1ns/1ps

module uart_top_tb;

    // Parameters for easy modification
    parameter CLK_FREQ = 50_000_000;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    parameter BAUD_RATE = 115200;
    parameter BAUD_PERIOD = 1_000_000_000 / BAUD_RATE;
    parameter DATA_BITS = 8;
    
    // Testbench signals
    logic clk;
    logic rst;
    logic tx_wr_en;
    logic [7:0] tx_wr_data;
    logic [DATA_BITS-1:0] rx_data_out;
    logic rx_data_valid;
    logic rx_frame_error;
    logic [3:0] tx_fifo_count;

    // Instantiate the Unit Under Test (UUT)
    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) i_uut (
        .clk(clk),
        .rst(rst),
        .tx_wr_en(tx_wr_en),
        .tx_wr_data(tx_wr_data),
        .rx_data_out(rx_data_out),
        .rx_data_valid(rx_data_valid),
        .rx_frame_error(rx_frame_error),
        .tx_fifo_count(tx_fifo_count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        $display("TB: Starting full UART loopback test");

        // 1. Initialize and apply reset
        rst = 0;
        tx_wr_en = 0;
        tx_wr_data = 8'h00;
        
        #(CLK_PERIOD * 10);
        rst = 1;
        #(CLK_PERIOD * 10);

        // 2. Test Case 1: Send a single character 'U' (8'h55)
        $display("TB: Sending character 'U' (8'h55)...");
        @(posedge clk);
        tx_wr_en = 1;
        tx_wr_data = 8'h55;
        @(posedge clk);
        tx_wr_en = 0;
        
        // Wait for the data to be transmitted and received
        repeat (1000) @(posedge clk); // Allow ample time for TX and RX

        // Check if the received data matches the sent data
        if (rx_data_valid && rx_data_out == 8'h55) begin
            $display("TB: Test Case 1 Passed! Sent: 8'h55, Received: %h", rx_data_out);
        end else begin
            $display("TB: Test Case 1 Failed! Expected 8'h55, got %h. Data valid: %b", rx_data_out, rx_data_valid);
            $display("    Frame Error: %b", rx_frame_error);
        end

        // 3. Test Case 2: Send a sequence of characters 'H', 'I'
        $display("\nTB: Sending sequence 'H' (8'h48) and 'I' (8'h49)...");
        @(posedge clk);
        tx_wr_en = 1;
        tx_wr_data = 8'h48;
        @(posedge clk);
        tx_wr_data = 8'h49;
        @(posedge clk);
        tx_wr_en = 0;

        // Wait for data to be received and check
        repeat (5000) @(posedge clk); // Wait for both to be received

        // Check the second character, as the first will likely be read already
        if (rx_data_valid && rx_data_out == 8'h49) begin
            $display("TB: Test Case 2 Passed! Received second character 'I' (8'h49).");
        end else begin
            $display("TB: Test Case 2 Failed! Expected 8'h49, got %h. Data valid: %b", rx_data_out, rx_data_valid);
        end

        // End the simulation
        $finish;
    end

    // Monitor key signals for debugging
    initial begin
        $monitor("[%0t] rx_data_out=%h, rx_data_valid=%b, rx_frame_error=%b",
                 $time, rx_data_out, rx_data_valid, rx_frame_error);
    end

    // Dump waveforms
    initial begin
        $dumpfile("uart_top_tb.vcd");
        $dumpvars(0, uart_top_tb);
    end

endmodule
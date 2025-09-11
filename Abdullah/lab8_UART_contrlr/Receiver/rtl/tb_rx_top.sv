`timescale 1ns/1ps

module tb_rx_top;

    // Parameters for easy modification
    parameter CLK_FREQ = 50_000_000;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    parameter BAUD_RATE = 115200;
    parameter BAUD_PERIOD = 1_000_000_000 / BAUD_RATE;
    parameter SAMPLES_PER_BIT = 16;
    parameter DATA_BITS = 8;
    
    // Testbench signals
    logic clk;
    logic rst;
    logic rxd;
    logic [DATA_BITS-1:0] received_data;
    logic data_valid;
    logic frame_error;
    logic overrun_error;

    // Instantiate the Unit Under Test (UUT)
    uart_rx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .SAMPLES_PER_BIT(SAMPLES_PER_BIT)
    ) i_uut (
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .data_out(received_data),
        .data_valid(data_valid),
        .frame_error(frame_error),
        .overrun_error(overrun_error)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // UART transmitter task
    task send_byte;
        input [7:0] tx_data;
        begin
            $display("TB: Transmitting byte: %h", tx_data);
            
            // Start bit (low)
            rxd = 1'b0;
            #(BAUD_PERIOD);

            // Data bits (LSB first)
            for (int i = 0; i < DATA_BITS; i++) begin
                rxd = tx_data[i];
                #(BAUD_PERIOD);
            end

            // Stop bit (high)
            rxd = 1'b1;
            #(BAUD_PERIOD);
        end
    endtask

    // Main test sequence
    initial begin
        $display("TB: Starting test sequence");

        // Initialize signals
        rst = 1'b1;
        rxd = 1'b1; // Idle state
        #(CLK_PERIOD * 10);
        rst = 1'b0;
        #(CLK_PERIOD * 10);

        // Test Case 1: Transmit a character 'A' (8'h41)
        send_byte(8'h41);
        #(BAUD_PERIOD * 5); // Wait for processing

        // Check the result
        if (received_data == 8'h41 && data_valid) begin
            $display("TB: Test Case 1 Passed. Received: %h", received_data);
        end else begin
            $display("TB: Test Case 1 Failed! Expected 8'h41, got %h", received_data);
        end

        // Test Case 2: Transmit another character
        send_byte(8'h55); // ASCII 'U'
        #(BAUD_PERIOD * 5);

        if (received_data == 8'h55 && data_valid) begin
            $display("TB: Test Case 2 Passed. Received: %h", received_data);
        end else begin
            $display("TB: Test Case 2 Failed!");
        end
        
        // Test Case 3: Simulate a frame error (stop bit is low)
        $display("TB: Simulating frame error...");
        rxd = 1'b0; // Start bit
        #(BAUD_PERIOD);
        rxd = 8'hFF; // Arbitrary data (all 1s)
        for (int i = 0; i < DATA_BITS; i++) begin
            rxd = 1'b1;
            #(BAUD_PERIOD);
        end
        rxd = 1'b0; // Intentional frame error
        #(BAUD_PERIOD);

        if (frame_error) begin
            $display("TB: Frame error test passed. Error detected.");
        end else begin
            $display("TB: Frame error test failed. No error detected.");
        end

        // End the simulation
        $finish;
    end

endmodule
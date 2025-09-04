`timescale 1ns / 1ps

module uart_transmitter_tb;

    // Signals
    logic clk, rst_n;
    logic [7:0] tx_data;
    logic tx_valid, tx_ready, tx_serial, tx_busy;
    
    // DUT
    uart_transmitter #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115200),
        .FIFO_DEPTH(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );
    
    // Clock
    always #10 clk = ~clk;
    
    // Test
    initial begin
        clk = 0;
        rst_n = 0;
        tx_data = 0;
        tx_valid = 0;
        
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(10) @(posedge clk);
        
        // Send first byte
        tx_data = 8'hA5;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        repeat(100) @(posedge clk);
        tx_data = 8'h3C;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

	wait(dut.em_flag & ~tx_busy);
	
        repeat(100) @(posedge clk);
        
        $finish;
    end
    
    initial begin
        $dumpfile("8A.vcd");
        $dumpvars;
    end

endmodule

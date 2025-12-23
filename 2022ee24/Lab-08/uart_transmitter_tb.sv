
module uart_transmitter_tb;
    
    // Testbench signals
    logic       clk;
    logic       rst_n;
    logic [7:0] tx_data;
    logic       tx_valid;
    logic       tx_ready;
    logic       tx_serial;
    logic       tx_busy;
    logic       fifo_full;
    logic       fifo_empty;
    logic       fifo_almost_full;
    logic       fifo_almost_empty;
    logic [3:0] fifo_count;
    
    // DUT instantiation
    uart_transmitter #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115200),
        .FIFO_DEPTH(8),
        .PARITY_EN(1'b0)
    ) dut (.*);
    
    // Clock generation
    always #10 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        tx_data = 0;
        tx_valid = 0;
        
        // Reset
        #100 rst_n = 1;
        #100;
        
        // Send byte 'A' (0x41)
        @(posedge clk);
        tx_data = 8'h41;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        
        // Wait and send another byte
        #100000;
        @(posedge clk);
        tx_data = 8'h42; // 'B'
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        #500;
        tx_data = 8'h4e;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        // End simulation
        #200000; 
        #200000;
        $stop;
    end

endmodule
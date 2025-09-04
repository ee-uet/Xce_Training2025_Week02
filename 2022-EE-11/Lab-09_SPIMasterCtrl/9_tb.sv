module SPI_tb;

// Clock and reset
logic clk;
logic rst;

// SPI inputs
logic [7:0] Din;
logic [15:0] ss_s_cycle;
logic [15:0] ss_h_cycle;  
logic [15:0] ss_t_cycle;
logic [15:0] dvsr;
logic start;
logic cpha;
logic cpol;
logic miso;

// SPI outputs
logic [7:0] Dout;
logic sclk;
logic spi_done_tick;
logic ready;
logic mosi;
logic ss_n_out;

// Instantiate the SPI module
SPI dut (
    .clk(clk),
    .rst(rst),
    .Din(Din),
    .ss_s_cycle(ss_s_cycle),
    .ss_h_cycle(ss_h_cycle),
    .ss_t_cycle(ss_t_cycle),
    .dvsr(dvsr),
    .start(start),
    .cpha(cpha),
    .cpol(cpol),
    .miso(miso),
    .Dout(Dout),
    .sclk(sclk),
    .spi_done_tick(spi_done_tick),
    .ready(ready),
    .mosi(mosi),
    .ss_n_out(ss_n_out)
);

// Clock generation
always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

// Test stimulus
initial begin
    // Initialize signals
    rst = 1;
    Din = 8'h00;
    ss_s_cycle = 16'd10;   // Short setup time
    ss_h_cycle = 16'd10;   // Short hold time
    ss_t_cycle = 16'd10;   // Short turn time
    dvsr = 16'd4;          // Clock divisor
    start = 0;
    cpha = 0;              // Clock phase 0
    cpol = 0;              // Clock polarity 0
    miso = 0;
    
    // Reset sequence
    #20;
    rst = 0;
    #20;
    
    $display("=== SPI Testbench Started ===");
    $display("Time\t\tReady\tStart\tDin\t\tMOSI\tMISO\tSCLK\tSS_N\tDone\tDout");
    $monitor("%0t\t%b\t%b\t%h\t%b\t%b\t%b\t%b\t%b\t%h", 
             $time, ready, start, Din, mosi, miso, sclk, ss_n_out, spi_done_tick, Dout);
    
    // Wait for ready
    wait(ready);
    #10;
    
    // Test 1: Send 0xA5 with MISO returning 0x3C
    $display("\n--- Test 1: Send 0xA5, expect MISO 0x3C ---");
    Din = 8'hA5;
    start = 1;
    #10;
    start = 0;
    
    // Simulate slave response during transmission
    fork
        begin
            // Wait a bit then start sending MISO data (MSB first: 0x3C = 00111100)
            #100;
            miso = 0; @(posedge sclk); // bit 7
            miso = 0; @(posedge sclk); // bit 6  
            miso = 1; @(posedge sclk); // bit 5
            miso = 1; @(posedge sclk); // bit 4
            miso = 1; @(posedge sclk); // bit 3
            miso = 1; @(posedge sclk); // bit 2
            miso = 0; @(posedge sclk); // bit 1
            miso = 0; @(posedge sclk); // bit 0
        end
    join_none
    
    // Wait for transaction to complete
    wait(spi_done_tick);
    #20;
    
    // Check result
    if (Dout == 8'h3C) begin
        $display("✓ Test 1 PASSED: Received correct data 0x%h", Dout);
    end else begin
        $display("✗ Test 1 FAILED: Expected 0x3C, got 0x%h", Dout);
    end
    
    // Wait for ready again
    wait(ready);
    #20;
    
    // Test 2: Send 0x55 with different MISO pattern
    $display("\n--- Test 2: Send 0x55, expect MISO 0xAA ---");
    Din = 8'h55;
    start = 1;
    #10;
    start = 0;
    
    // Simulate slave response (0xAA = 10101010)
    fork
        begin
            #100;
            miso = 1; @(posedge sclk); // bit 7
            miso = 0; @(posedge sclk); // bit 6
            miso = 1; @(posedge sclk); // bit 5
            miso = 0; @(posedge sclk); // bit 4
            miso = 1; @(posedge sclk); // bit 3
            miso = 0; @(posedge sclk); // bit 2
            miso = 1; @(posedge sclk); // bit 1
            miso = 0; @(posedge sclk); // bit 0
        end
    join_none
    
    wait(spi_done_tick);
    #20;
    
    if (Dout == 8'hAA) begin
        $display("✓ Test 2 PASSED: Received correct data 0x%h", Dout);
    end else begin
        $display("✗ Test 2 FAILED: Expected 0xAA, got 0x%h", Dout);
    end
    
    wait(ready);
    #20;
    
    // Test 3: Test with different clock polarity
    $display("\n--- Test 3: Send 0xFF with CPOL=1 ---");
    cpol = 1;
    Din = 8'hFF;
    start = 1;
    #10;
    start = 0;
    
    // Simple MISO pattern
    fork
        begin
            #100;
            repeat(8) begin
                miso = $random;
                @(posedge sclk);
            end
        end
    join_none
    
    wait(spi_done_tick);
    #20;
    $display("✓ Test 3 COMPLETED: CPOL=1 test done, Dout=0x%h", Dout);
    
    wait(ready);
    #50;
    
    $display("\n=== All Tests Completed ===");
    $finish;
end

initial begin
	$dumpfile("9.vcd");
	$dumpvars;
end

endmodule

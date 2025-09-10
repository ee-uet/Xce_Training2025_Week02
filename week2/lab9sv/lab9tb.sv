module spi_master_tb();
    parameter NUM_SLAVES = 1;
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;
    
    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
    logic start_transfer;
    logic cpol;
    logic cpha;
    logic [15:0] clk_div;
    logic [DATA_WIDTH-1:0] rx_data;
    logic transfer_done;
    logic busy;
    logic spi_clk;
    logic spi_mosi;
    logic spi_miso;
    logic [NUM_SLAVES-1:0] spi_cs_n;
    
    // Instantiate SPI Master
    spi_master dut (.*);
    
    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Slave for Mode 1 (CPOL=0, CPHA=1)
    // In Mode 1: Slave changes MISO on rising edge, Master samples on falling edge
    logic [2:0] bit_count;
    always @(negedge spi_clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_miso <= 0;
            bit_count <= 0;
        end else if (spi_cs_n[0] == 0) begin
            // Return fixed pattern: 0x5A = 01011010
            case (bit_count)
                0: spi_miso <= 0; // bit 7
                1: spi_miso <= 1; // bit 6
                2: spi_miso <= 0; // bit 5
                3: spi_miso <= 1; // bit 4
                4: spi_miso <= 1; // bit 3
                5: spi_miso <= 0; // bit 2
                6: spi_miso <= 1; // bit 1
                7: spi_miso <= 0; // bit 0
            endcase
            bit_count <= bit_count + 1;
        end else begin
            spi_miso <= 0;
            bit_count <= 0;
        end
    end
    
    // Test sequence for Mode 1
    initial begin
        clk = 0;
        rst_n = 0;
        tx_data = 0;
        slave_sel = 0;
        start_transfer = 0;
        cpol = 1;  // Mode 1: CPOL=0
        cpha = 1;  // Mode 1: CPHA=1
        clk_div = 4;
        
        $display("=== Testing SPI Mode 1 (CPOL=0, CPHA=1) ===");
        
        // Apply reset
        #20 rst_n = 1;
        #20;
        
        // Single transfer
        tx_data = 8'hA5;
        start_transfer = 1;
        #CLK_PERIOD;
        start_transfer = 0;
        
        $display("Sending: 0x%h", tx_data);
        
        // Wait for completion
        wait(transfer_done);
        
        $display("Received: 0x%h (Expected: 0x5A)", rx_data);
        
        if (rx_data === 8'h5A) 
            $display("✓ Mode 1 Test PASSED!");
        else
            $display("✗ Mode 1 Test FAILED!");
        
        #100;
        $finish;
    end
    
endmodule
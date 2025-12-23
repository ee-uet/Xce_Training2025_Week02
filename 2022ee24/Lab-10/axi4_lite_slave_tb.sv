module axi4_lite_slave_tb();

    // Clock and reset
    logic clk;
    logic rst_n;
    
    // AXI interface
    axi4_lite_if axi_if();
    
    // Instantiate DUT
    axi4_lite_slave_v2 dut (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_if.slave)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Main test
    initial begin
        
        $display("Starting basic AXI4-Lite test");
        
        // Initialize
        axi_if.awaddr = 0;
        axi_if.awvalid = 0;
        axi_if.wdata = 0;
        axi_if.wstrb = 0;
        axi_if.wvalid = 0;
        axi_if.bready = 0;
        axi_if.araddr = 0;
        axi_if.arvalid = 0;
        axi_if.rready = 0;
        
        // Reset
        rst_n = 0;
        #20;
        rst_n = 1;
        #20;

        // Test 1: Simple write
        $display("Test 1: Writing to register 0");
        @(posedge clk);
        axi_if.awaddr = 32'h40000000;  // Register 0
        axi_if.awvalid = 1;
        axi_if.wdata = 32'h12345678;
        axi_if.wstrb = 4'b1111;
        axi_if.wvalid = 1;
        axi_if.bready = 1;

        wait(axi_if.awready);
        @(posedge clk);
        axi_if.awvalid = 0;
        
        wait(axi_if.wready);
        @(posedge clk);
        axi_if.wvalid = 0;
        
        wait(axi_if.bvalid);
        @(posedge clk);
        axi_if.bready = 0;
        #20;

        // Test 2: Simple read
        $display("Test 2: Reading from register 0");
        @(posedge clk);
        axi_if.araddr = 32'h40000000;  // Register 0
        axi_if.arvalid = 1;
        axi_if.rready = 1;

        wait(axi_if.arready);
        @(posedge clk);
        axi_if.arvalid = 0;
        
        wait(axi_if.rvalid);
        $display("Read data: 0x%08h", axi_if.rdata);
        @(posedge clk);
        axi_if.rready = 0;
        #20;

        // Test 3: Write to another register
        $display("Test 3: Writing to register 4");
        @(posedge clk);
        axi_if.awaddr = 32'h40000004;  // Register 1
        axi_if.awvalid = 1;
        axi_if.wdata = 32'hAABBCCDD;
        axi_if.wstrb = 4'b1100;
        axi_if.wvalid = 1;
        axi_if.bready = 1;

        wait(axi_if.awready);
        @(posedge clk);
        axi_if.awvalid = 0;
        
        wait(axi_if.wready);
        @(posedge clk);
        axi_if.wvalid = 0;
        
        wait(axi_if.bvalid);
        @(posedge clk);
        axi_if.bready = 0;
        #20;

        // Test 4: Read from the second register
        $display("Test 4: Reading from register 4");
        @(posedge clk);
        axi_if.araddr = 32'h40000004;  // Register 1
        axi_if.arvalid = 1;
        axi_if.rready = 1;

        wait(axi_if.arready);
        @(posedge clk);
        axi_if.arvalid = 0;
        
        wait(axi_if.rvalid);
        $display("Read data: 0x%08h", axi_if.rdata);
        @(posedge clk);
        axi_if.rready = 0;
        #20;

        $display("Basic test completed");
        #100;
        $finish;

    end

endmodule
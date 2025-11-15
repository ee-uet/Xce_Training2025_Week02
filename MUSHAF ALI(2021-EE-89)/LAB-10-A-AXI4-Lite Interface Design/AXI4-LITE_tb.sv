module axi4_slave_tb;
    logic clk, rst;
    logic valid, invalid;
    logic [3:0] index;
    logic read_valid, read_invalid;
    logic [3:0] read_index;

    // Instantiate the interface
    axi4_lite axi_if();

    // Instantiate the write decoder
    decoder write_dec (
        .S(axi_if.slave),
        .valid(valid),
        .invalid(invalid),
        .index(index)
    );

    // Instantiate the read decoder
    read_decoder read_dec (
        .S(axi_if.slave),
        .read_valid(read_valid),
        .read_invalid(read_invalid),
        .read_index(read_index)
    );

    // Instantiate the slave
    axi4_slave dut (
        .S(axi_if.slave),
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .invalid(invalid),
        .index(index),
        .read_valid(read_valid),
        .read_invalid(read_invalid),
        .read_index(read_index)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1;
        axi_if.ARADDR = 0;
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;
        axi_if.AWADDR = 0;
        axi_if.AWVALID = 0;
        axi_if.WDATA = 0;
        axi_if.WVALID = 0;
        axi_if.WSTRB = 0;
        axi_if.BREADY = 0;

        // Reset the DUT
        #20 rst = 0;
        $display("Test: Reset released at time %0t", $time);

        // Test 1: Valid write to 0x40000000 (register 0), then read back
        #10;
        $display("Test 1: Writing to valid address 0x40000000 (register 0)");
        axi_if.AWADDR = 32'h40000000;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'hDEADBEEF;
        axi_if.WSTRB = 4'hF; // Full word write
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b00)
            $display("Write Passed: BRESP = %b (OKAY)", axi_if.BRESP);
        else
            $display("Write Failed: BRESP = %b (expected 2'b00)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        $display("Reading back from 0x40000000");
        axi_if.ARADDR = 32'h40000000;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RDATA == 32'hDEADBEEF && axi_if.RRESP == 2'b00)
            $display("Test 1 Passed: RDATA = %h, RRESP = %b", axi_if.RDATA, axi_if.RRESP);
        else
            $display("Test 1 Failed: RDATA = %h, RRESP = %b (expected RDATA = %h, RRESP = 2'b00)", 
                     axi_if.RDATA, axi_if.RRESP, 32'hDEADBEEF);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 2: Valid write to 0x4000003C (register 15), then read back
        #20;
        $display("Test 2: Writing to valid address 0x4000003C (register 15)");
        axi_if.AWADDR = 32'h4000003C;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'h12345678;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b00)
            $display("Write Passed: BRESP = %b (OKAY)", axi_if.BRESP);
        else
            $display("Write Failed: BRESP = %b (expected 2'b00)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        $display("Reading back from 0x4000003C");
        axi_if.ARADDR = 32'h4000003C;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RDATA == 32'h12345678 && axi_if.RRESP == 2'b00)
            $display("Test 2 Passed: RDATA = %h, RRESP = %b", axi_if.RDATA, axi_if.RRESP);
        else
            $display("Test 2 Failed: RDATA = %h, RRESP = %b (expected RDATA = %h, RRESP = 2'b00)", 
                     axi_if.RDATA, axi_if.RRESP, 32'h12345678);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 3: Misaligned write to 0x40000001, expect SLVERR
        #20;
        $display("Test 3: Writing to misaligned address 0x40000001");
        axi_if.AWADDR = 32'h40000001;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'hABCDEF01;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b10)
            $display("Test 3 Passed: BRESP = %b (SLVERR)", axi_if.BRESP);
        else
            $display("Test 3 Failed: BRESP = %b (expected 2'b10)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        // Test 4: Out-of-range write to 0x40000040, expect SLVERR
        #20;
        $display("Test 4: Writing to out-of-range address 0x40000040");
        axi_if.AWADDR = 32'h40000040;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'hFEDCBA98;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b10)
            $display("Test 4 Passed: BRESP = %b (SLVERR)", axi_if.BRESP);
        else
            $display("Test 4 Failed: BRESP = %b (expected 2'b10)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        // Test 5: Partial write with WSTRB=4'h3 (lower 16 bits) to 0x40000010, read back
        #20;
        $display("Test 5: Partial writing to 0x40000010 (register 4) with WSTRB=4'h3");
        axi_if.AWADDR = 32'h40000010;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'hFFEEDDCC;
        axi_if.WSTRB = 4'h3; // Write lower 16 bits only
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b00)
            $display("Write Passed: BRESP = %b (OKAY)", axi_if.BRESP);
        else
            $display("Write Failed: BRESP = %b (expected 2'b00)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        $display("Reading back from 0x40000010 (expect lower 16 bits DDCC, upper 16 0000)");
        axi_if.ARADDR = 32'h40000010;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RDATA == 32'h0000DDCC && axi_if.RRESP == 2'b00)
            $display("Test 5 Passed: RDATA = %h, RRESP = %b", axi_if.RDATA, axi_if.RRESP);
        else
            $display("Test 5 Failed: RDATA = %h, RRESP = %b (expected RDATA = 0x0000DDCC, RRESP = 2'b00)", 
                     axi_if.RDATA, axi_if.RRESP);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 6: Back-to-back writes to 0x40000004 and 0x40000008, then read back
        #20;
        $display("Test 6: Back-to-back writes to 0x40000004 (register 1) and 0x40000008 (register 2)");
        // Write to 0x40000004
        axi_if.AWADDR = 32'h40000004;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'hAABBCCDD;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b00)
            $display("Write 6a Passed: BRESP = %b (OKAY)", axi_if.BRESP);
        else
            $display("Write 6a Failed: BRESP = %b (expected 2'b00)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        // Write to 0x40000008
        axi_if.AWADDR = 32'h40000008;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'h11223344;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        @(posedge clk);
        axi_if.BREADY = 1;
        wait (axi_if.BVALID == 1);
        @(posedge clk);
        if (axi_if.BRESP == 2'b00)
            $display("Write 6b Passed: BRESP = %b (OKAY)", axi_if.BRESP);
        else
            $display("Write 6b Failed: BRESP = %b (expected 2'b00)", axi_if.BRESP);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        // Read back from 0x40000004
        $display("Reading back from 0x40000004");
        axi_if.ARADDR = 32'h40000004;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RDATA == 32'hAABBCCDD && axi_if.RRESP == 2'b00)
            $display("Test 6a Read Passed: RDATA = %h, RRESP = %b", axi_if.RDATA, axi_if.RRESP);
        else
            $display("Test 6a Read Failed: RDATA = %h, RRESP = %b (expected RDATA = %h, RRESP = 2'b00)", 
                     axi_if.RDATA, axi_if.RRESP, 32'hAABBCCDD);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Read back from 0x40000008
        $display("Reading back from 0x40000008");
        axi_if.ARADDR = 32'h40000008;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RDATA == 32'h11223344 && axi_if.RRESP == 2'b00)
            $display("Test 6b Read Passed: RDATA = %h, RRESP = %b", axi_if.RDATA, axi_if.RRESP);
        else
            $display("Test 6b Read Failed: RDATA = %h, RRESP = %b (expected RDATA = %h, RRESP = 2'b00)", 
                     axi_if.RDATA, axi_if.RRESP, 32'h11223344);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 7: Misaligned read to 0x40000001, expect SLVERR
        #20;
        $display("Test 7: Reading from misaligned address 0x40000001");
        axi_if.ARADDR = 32'h40000001;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RRESP == 2'b10)
            $display("Test 7 Passed: RRESP = %b (SLVERR)", axi_if.RRESP);
        else
            $display("Test 7 Failed: RRESP = %b (expected 2'b10)", axi_if.RRESP);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 8: Out-of-range read to 0x40000040, expect SLVERR
        #20;
        $display("Test 8: Reading from out-of-range address 0x40000040");
        axi_if.ARADDR = 32'h40000040;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        @(posedge clk);
        axi_if.RREADY = 1;
        wait (axi_if.RVALID == 1);
        @(posedge clk);
        if (axi_if.RRESP == 2'b10)
            $display("Test 8 Passed: RRESP = %b (SLVERR)", axi_if.RRESP);
        else
            $display("Test 8 Failed: RRESP = %b (expected 2'b10)", axi_if.RRESP);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // Test 9: Reset during write transaction
        #20;
        $display("Test 9: Reset during write transaction");
        axi_if.AWADDR = 32'h40000020;
        axi_if.AWVALID = 1;
        wait (axi_if.AWREADY == 1);
        @(posedge clk);
        axi_if.WDATA = 32'h55555555;
        axi_if.WSTRB = 4'hF;
        axi_if.WVALID = 1;
        wait (axi_if.WREADY == 1);
        #5 rst = 1; // Assert reset mid-transaction
        #10 rst = 0;
        axi_if.BREADY = 1;
        #20;
        if (axi_if.BVALID == 0 && axi_if.AWREADY == 1 && axi_if.WREADY == 0)
            $display("Test 9 Passed: Reset correctly handled");
        else
            $display("Test 9 Failed: BVALID = %b, AWREADY = %b, WREADY = %b", axi_if.BVALID, axi_if.AWREADY, axi_if.WREADY);
        axi_if.AWVALID = 0;
        axi_if.WVALID = 0;
        axi_if.BREADY = 0;

        // Test 10: Reset during read transaction
        #20;
        $display("Test 10: Reset during read transaction");
        axi_if.ARADDR = 32'h40000020;
        axi_if.ARVALID = 1;
        wait (axi_if.ARREADY == 1);
        #5 rst = 1; // Assert reset mid-transaction
        #10 rst = 0;
        axi_if.RREADY = 1;
        #20;
        if (axi_if.RVALID == 0 && axi_if.ARREADY == 1)
            $display("Test 10 Passed: Reset correctly handled");
        else
            $display("Test 10 Failed: RVALID = %b, ARREADY = %b", axi_if.RVALID, axi_if.ARREADY);
        axi_if.ARVALID = 0;
        axi_if.RREADY = 0;

        // End simulation
        #20 $display("All tests completed");
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t rst=%b AWADDR=%h AWVALID=%b AWREADY=%b WDATA=%h WVALID=%b WREADY=%b WSTRB=%h BVALID=%b BRESP=%b BREADY=%b ARADDR=%h ARVALID=%b ARREADY=%b RDATA=%h RVALID=%b RRESP=%b RREADY=%b write_state=%s read_state=%s",
                 $time, rst, axi_if.AWADDR, axi_if.AWVALID, axi_if.AWREADY, axi_if.WDATA, axi_if.WVALID, axi_if.WREADY, axi_if.WSTRB, axi_if.BVALID, axi_if.BRESP, axi_if.BREADY,
                 axi_if.ARADDR, axi_if.ARVALID, axi_if.ARREADY, axi_if.RDATA, axi_if.RVALID, axi_if.RRESP, axi_if.RREADY,
                 dut.current_state.name, dut.read_current_state.name);
    end
endmodule
`timescale 1ns/1ps

module tb_axi4_lite_slave;

    // -------------------------
    // Clock and Reset
    // -------------------------
    logic clk;
    logic rst_n;

    // AXI4-Lite Interface
    axi4_lite_if axi_if();

    // DUT
    axi4_lite_slave dut (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_if)
    );

    // -------------------------
    // Clock Generation
    // -------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // -------------------------
    // Reset
    // -------------------------
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // -------------------------
    // Simple Stimulus (2 writes, 2 reads)
    // -------------------------
    initial begin
        // Initialize
        axi_if.awaddr  = 0;
        axi_if.awvalid = 0;
        axi_if.wdata   = 0;
        axi_if.wstrb   = 0;
        axi_if.wvalid  = 0;
        axi_if.bready  = 0;
        axi_if.araddr  = 0;
        axi_if.arvalid = 0;
        axi_if.rready  = 0;

        @(posedge rst_n); // wait for reset
        #10;

        // -------------------------
        // Write #1: reg[0] = 0xabcdeffc
        // -------------------------
        @(posedge clk);
		
        axi_if.awaddr  <= 32'h0000_0000;
        axi_if.awvalid <= 1;
		
        repeat (2) @(posedge clk);
		
        axi_if.awvalid <= 0;
        axi_if.wdata   <= 32'habcdeffc;
        axi_if.wstrb   <= 4'b1111;
        axi_if.wvalid  <= 1;
		
        @(posedge clk);
		axi_if.bready  <= 1;
		@(posedge clk);
        axi_if.wvalid  <= 0;
        
		
        repeat (2) @(posedge clk);
        axi_if.bready  <= 0;

        // -------------------------
        // Write #2: reg[1] = 0x12345678
        // -------------------------
       
        @(posedge clk);
		
        axi_if.awaddr  <= 32'h0000_0008;
        axi_if.awvalid <= 1;
		
        repeat (2) @(posedge clk);
		
        axi_if.awvalid <= 0;
        axi_if.wdata   <= 32'h00560078;
        axi_if.wstrb   <= 4'b0101;
        axi_if.wvalid  <= 1;
		
        @(posedge clk);
		axi_if.bready  <= 1;
		@(posedge clk);
        axi_if.wvalid  <= 0;
		
        repeat (2) @(posedge clk);
        axi_if.bready  <= 0;
		
		// -------------------------
		// Read #1: reg[0]
        // -------------------------
        @(posedge clk);
        axi_if.araddr  <= 32'h0000_0000;
        axi_if.arvalid <= 1;
        repeat (2) @(posedge clk);
        axi_if.arvalid <= 0;

        axi_if.rready <= 1;
        wait(axi_if.rvalid);
        @(posedge clk);
        axi_if.rready <= 0;

        // -------------------------
        // Read #2: reg[1]
        // -------------------------
        @(posedge clk);
        axi_if.araddr  <= 32'h0000_0008;
        axi_if.arvalid <= 1;
        @(posedge clk);
        axi_if.arvalid <= 0;

        axi_if.rready <= 1;
        wait(axi_if.rvalid);
        @(posedge clk);
        axi_if.rready <= 0;
		#20
        $finish;
    end

endmodule

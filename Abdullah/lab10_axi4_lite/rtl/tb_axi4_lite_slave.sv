`timescale 1ns/1ps

module tb_axi4_lite_slave;

    // Clock & reset
    logic clk;
    logic rst_n;

    // Instantiate interface
    axi4_lite_if axi_if();

    // DUT
    axi4_lite_slave dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .axi_if (axi_if.slave)
    );

    // Generate clock
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Reset sequence
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // -------------------------------------------------
    // AXI4-Lite Master Tasks
    // -------------------------------------------------
    task automatic axi_write(input [31:0] addr, input [31:0] data, input [3:0] strb);
        begin
            // Address handshake
            axi_if.awaddr  <= addr;
            axi_if.awvalid <= 1'b1;
            @(posedge clk);
            wait(axi_if.awready);
            @(posedge clk);
            axi_if.awvalid <= 0;

            // Data handshake
            axi_if.wdata   <= data;
            axi_if.wstrb   <= strb;
            axi_if.wvalid  <= 1'b1;
            @(posedge clk);
            wait(axi_if.wready);
            @(posedge clk);
            axi_if.wvalid  <= 0;

            // Response handshake
            axi_if.bready  <= 1'b1;
            wait(axi_if.bvalid);
            $display("[%0t] WRITE ADDR=0x%08h DATA=0x%08h STRB=%b BRESP=%b",
                      $time, addr, data, strb, axi_if.bresp);
            @(posedge clk);
            axi_if.bready  <= 0;
        end
    endtask

    task automatic axi_read(input [31:0] addr, output [31:0] data);
        begin
            // Address handshake
            axi_if.araddr  <= addr;
            axi_if.arvalid <= 1'b1;
            @(posedge clk);
            wait(axi_if.arready);
            @(posedge clk);
            axi_if.arvalid <= 0;

            // Data handshake
            axi_if.rready  <= 1'b1;
            wait(axi_if.rvalid);
            data = axi_if.rdata;
            $display("[%0t] READ  ADDR=0x%08h DATA=0x%08h RRESP=%b",
                      $time, addr, data, axi_if.rresp);
            @(posedge clk);
            axi_if.rready  <= 0;
        end
    endtask

    logic [31:0] rd_data;
    // -------------------------------------------------
    // Test Sequence
    // -------------------------------------------------
    initial begin
        // Initialize signals
        axi_if.awaddr  = 0;
        axi_if.awvalid = 0;
        axi_if.wdata   = 0;
        axi_if.wstrb   = 0;
        axi_if.wvalid  = 0;
        axi_if.bready  = 0;
        axi_if.araddr  = 0;
        axi_if.arvalid = 0;
        axi_if.rready  = 0;
        // axi_if.arready = 0;
        // axi_if.awready = 0;
        // addr_valid_read = 0;
        // addr_valid_write = 0;

        @(posedge rst_n); // wait until reset released
        @(posedge clk);

        // -------------------------------
        // 1. Simple word write and read
        // -------------------------------
        axi_write(32'h0000_0000, 32'hDEADBEEF, 4'b1111);
        #10;

        axi_read(32'h0000_0000, rd_data);

        // -------------------------------
        // 2. Partial write (WSTRB test)
        // -------------------------------
        axi_write(32'h0000_0004, 32'hAAAA_BBBB, 4'b1100); // update upper 2 bytes only
        #10;
        axi_read(32'h0000_0004, rd_data);

        // -------------------------------
        // 3. Invalid address (DECERR)
        // -------------------------------
        axi_write(32'h0000_1000, 32'h12345678, 4'b1111); // out of range
        #10;
        axi_read(32'h0000_1000, rd_data);

        // -------------------------------
        // 4. WSTRB = 0 (should ignore or DECERR depending on design)
        // -------------------------------
        axi_write(32'h0000_0008, 32'hCAFEBABE, 4'b0000);
        #10;
        axi_read(32'h0000_0008, rd_data);

        // -------------------------------
        // 5. Back-to-back writes & reads
        // -------------------------------
        
        axi_write(32'h0000_000C, 32'h11111111, 4'b1111);
        axi_write(32'h0000_0010, 32'h22222222, 4'b1111);

        #10;
        axi_read(32'h0000_000C, rd_data);
        axi_read(32'h0000_0010, rd_data);

        #50;
        $display("Simulation completed.");
        $finish;
    end

endmodule

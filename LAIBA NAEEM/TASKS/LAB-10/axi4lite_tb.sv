`timescale 1ns/1ps
`default_nettype none

module tb_axi4_lite;

  // Clock/Reset
  logic ACLK;
  logic ARESETn;

  // Instantiate interface (no params, no ports on the interface itself)
  axi4_lite_if axi();

  // DUT (matches your module header)
  axi4_lite_slave dut (
    .clk    (ACLK),
    .rst_n  (ARESETn),
    .axi_if (axi)
  );

  // 100 MHz clock (10 ns period)
  initial ACLK = 1'b0;
  always  #5 ACLK = ~ACLK;

  // Stimulus
  initial begin
    // Master outputs default low
    axi.awaddr  = '0;
    axi.awvalid = 1'b0;
    axi.wdata   = '0;
    axi.wstrb   = 4'h0;
    axi.wvalid  = 1'b0;
    axi.bready  = 1'b0;

    axi.araddr  = '0;
    axi.arvalid = 1'b0;
    axi.rready  = 1'b0;

    // Reset sequence
    ARESETn = 1'b0;
    repeat (4) @(posedge ACLK);
    ARESETn = 1'b1;
    @(posedge ACLK);

    
    // Write: 
   
    axi.awaddr  = 32'h0000_0008;
    axi.awvalid = 1'b1;

    axi.wdata   = 32'habcd4522;
    axi.wstrb   = 4'hF;
    axi.wvalid  = 1'b1;

    axi.bready  = 1'b1; // master is ready to accept the response
 
    // Handshake AW/W (allow either order)
    wait (axi.awvalid && axi.awready);
    $display("[%0t] WRITE-ADDR: AWADDR=0x%08h  AWVALID=%0b  AWREADY=%0b",
             $time, axi.awaddr, axi.awvalid, axi.awready);
    @(posedge ACLK);
    axi.awvalid = 1'b0;

    wait (axi.wvalid && axi.wready);
    $display("[%0t] WRITE-DATA: WDATA=0x%08h  WSTRB=0x%1h  WVALID=%0b  WREADY=%0b",
             $time, axi.wdata, axi.wstrb, axi.wvalid, axi.wready);
    @(posedge ACLK);
    axi.wvalid = 1'b0;

    // Wait for write response
    wait (axi.bvalid);
    $display("[%0t] WRITE-RESP: BRESP=%0d  BVALID=%0b  BREADY=%0b",
             $time, axi.bresp, axi.bvalid, axi.bready);
    @(posedge ACLK);
    axi.bready = 1'b0;   // consume BVALID
    @(posedge ACLK);

   
    // Read back:
    
    axi.araddr  = 32'h0000_0008;
    axi.arvalid = 1'b1;
    axi.rready  = 1'b1;

    // Handshake AR
    wait (axi.arvalid && axi.arready);
    $display("[%0t] READ-ADDR:  ARADDR=0x%08h  ARVALID=%0b  ARREADY=%0b",
             $time, axi.araddr, axi.arvalid, axi.arready);
    @(posedge ACLK);
    axi.arvalid = 1'b0;

    // Wait for RDATA
    wait (axi.rvalid);
    $display("[%0t] READ-DATA:  RDATA=0x%08h  RRESP=%0d  RVALID=%0b  RREADY=%0b",
             $time, axi.rdata, axi.rresp, axi.rvalid, axi.rready);
    @(posedge ACLK);
    axi.rready = 1'b0;

    // Finish
    repeat (5) @(posedge ACLK);
    $finish;
  end

endmodule



module axi4_lite_slave_tb; 

logic clk; 
logic rst_n;

// Instantiate interface
axi4_lite_if axi_if();

// Instantiate DUT
axi4_lite_slave dut (
    .clk(clk),
    .rst_n(rst_n),
    .axi_if(axi_if.slave)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test stimulus
initial begin
    // Initialize signals
    rst_n = 0;
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
    #20 rst_n = 1;
    
    // Write transaction
    #10;
    axi_if.awaddr = 32'h4;   // Address 4
    axi_if.awvalid = 1;
    @(posedge clk);
    wait(axi_if.awready);
    @(posedge clk);
    axi_if.awvalid = 0;
    
    axi_if.wdata = 32'hDEADBEEF;
    axi_if.wstrb = 4'b1111;
    axi_if.wvalid = 1;
    @(posedge clk);
    wait(axi_if.wready);
    @(posedge clk);
    axi_if.wvalid = 0;
    
    axi_if.bready = 1;
    @(posedge clk);
    wait(axi_if.bvalid);
    @(posedge clk);
    axi_if.bready = 0;
    
    // Read transaction
    #10;
    axi_if.araddr = 32'h4;   // Same address
    axi_if.arvalid = 1;
    @(posedge clk);
    wait(axi_if.arready);
    @(posedge clk);
    axi_if.arvalid = 0;
    
    axi_if.rready = 1;
    wait(axi_if.rvalid);
    @(posedge clk);
    if (axi_if.rdata == 32'hDEADBEEF)
        $display("Test Passed: Read data matches written data");
    else
        $display("Test Failed: Expected 0xDEADBEEF, got 0x%h", axi_if.rdata);
    axi_if.rready = 0;
    
    // End simulation
    #100;
    $stop;
end
endmodule
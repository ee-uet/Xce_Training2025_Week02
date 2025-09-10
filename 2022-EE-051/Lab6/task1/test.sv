module tb_sram_controller;

    logic clk, rst_n;
    logic read_req, write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce_n, sram_oe_n, sram_we_n;

  
    sram_controller dut (.*);

    // Simple SRAM model (32K x 16)
    logic [15:0] mem [0:32767];
    logic [15:0] sram_data_drv;

    assign sram_data = sram_data_drv;

    // write into memory
    always_ff @(posedge clk) begin
        if (sram_ce_n==0 && sram_we_n==0) begin
            mem[sram_addr] <= sram_data;
        end
    end

    // read from memory 
    always_comb begin
        if (sram_ce_n==0 && sram_oe_n==0 && sram_we_n==1) begin
            sram_data_drv = mem[sram_addr];
        end else begin
            sram_data_drv = 16'hzzzz;
        end
    end

    initial clk = 0;
    always #5 clk = ~clk; 

    // Test sequence
    initial begin
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;
        #20;
        rst_n = 1;

        // Write operation
        @(posedge clk);
        address    = 15'h0010;
        write_data = 16'hABCD;
        write_req  = 1;
        @(posedge clk);
        write_req  = 0;

        // Read operation
        @(posedge clk);
        address   = 15'h0010;
        read_req  = 1;
        @(posedge clk);
        read_req  = 0;

        // wait for read to settle
        @(posedge clk);
$display("Read Data = %h, Expected = %h", read_data, 16'hABCD);
if (read_data === 16'hABCD) 
    $display("TEST PASSED");
else 
    $fatal(1, "TEST FAILED");
$stop;
    end

endmodule

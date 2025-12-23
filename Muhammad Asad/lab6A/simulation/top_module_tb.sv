

module top_module_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic read_req;
    logic write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce;
    logic        sram_oe;
    logic        sram_we;

    

    // Connect top_module
    top_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .read_req(read_req),
        .write_req(write_req),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .ready(ready),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_ce(sram_ce),
        .sram_oe(sram_oe),
        .sram_we(sram_we)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    

    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;
        #3;
        rst_n = 1;

        // Write test
        @(posedge clk);
        address = 15'h0010;
        write_data = 16'hABCD;
        write_req = 1;
        @(posedge clk);
        write_req = 0;
        
        

        // Read test
        @(posedge clk);
        @(posedge clk);
        address = 15'h0010;
        read_req = 1;
        @(posedge clk);
        read_req = 0;
        

        

        $finish;
    end

endmodule
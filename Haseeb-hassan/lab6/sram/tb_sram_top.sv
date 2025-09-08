`timescale 1ns/1ps
module tb_sram_top;

    logic        clk;
    logic        rst_n;
    logic        read_req;
    logic        write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic        ready;
    
    // SRAM interface
    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce_n;
    logic        sram_oe_n;
    logic        sram_we_n;

    // Simple SRAM model for testing
    logic [15:0] sram_memory [0:32767]; // 32K x 16-bit
    
    // SRAM behavioral model
    assign sram_data = (!sram_ce_n && !sram_oe_n && sram_we_n) ? sram_memory[sram_addr] : 16'bz;
    
    always_comb begin
        if (!sram_ce_n && !sram_we_n && sram_oe_n) begin
            sram_memory[sram_addr] = sram_data;
        end
    end

    // Instantiate DUT
    sram_top UUT (
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
        .sram_ce_n(sram_ce_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    initial begin
    // Initialize
    rst_n = 0;
    read_req = 0;
    write_req = 0;
    address = 0;
    write_data = 0;
    
    #20 rst_n = 1;
    #20;
    
    // Simple write test
    address = 15'h1234;
    write_data = 16'hABCD;
    write_req = 1;
    #10 write_req = 0;
    #100; // Wait fixed time instead of @(posedge ready)
    
    $finish;
end
endmodule
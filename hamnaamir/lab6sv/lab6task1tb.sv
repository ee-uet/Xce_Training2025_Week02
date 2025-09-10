`timescale 1ns/1ps

module tb_sram_controller;
    logic clk, rst_n;
    logic read_req, write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic sram_ce_n, sram_oe_n, sram_we_n;

    // simple SRAM (array model)
    logic [15:0] sram [0:(1<<15)-1];
    tri [15:0]   sram_bus;

    assign sram_data = sram_bus;

    // emulate SRAM drive
    assign sram_bus = (!sram_ce_n && !sram_oe_n && sram_we_n) ? sram[sram_addr] : 16'hZZZZ;
    always @(negedge sram_we_n) if (!sram_ce_n) sram[sram_addr] <= sram_data;

    // DUT
    sram_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .read_req(read_req),
        .write_req(write_req),
        .address(address), 
        .write_data(write_data),
        .read_data(read_data),
        .ready(ready),
        .sram_addr(sram_addr), 
        .sram_data(sram_bus),
        .sram_ce_n(sram_ce_n), 
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;

    // stimulus
    initial begin
        rst_n = 0; read_req = 0; write_req = 0;
        address = 0; write_data = 0;
        #12 rst_n = 1;

        // write 
        @(posedge clk);
        address = 15'h000A; write_data = 16'h1234; write_req = 1;
        @(posedge clk) write_req = 0;

        // read back
        @(posedge clk);
        address = 15'h000A; read_req = 1;
        @(posedge clk) read_req = 0;

        // check
        #10 $display("Read data = 0x%h (expected 0x1234)", read_data);
        $finish;
    end
endmodule

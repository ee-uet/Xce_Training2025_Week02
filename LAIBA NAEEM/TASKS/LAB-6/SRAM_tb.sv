`timescale 1ns/1ps

module sram_controller_tb;

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
    wire [15:0] sram_data;
    logic sram_ce_n;
    logic sram_oe_n;
    logic sram_we_n;

    // Instantiate the DUT
    sram_controller uut (
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

    // Simple SRAM model (for simulation)
    logic [15:0] mem [0:32767]; // 32K words

    assign sram_data = (uut.current_state == uut.write) ? write_data : mem[sram_addr];

    always_ff @(posedge clk) begin
        if (uut.current_state == uut.write)
            mem[sram_addr] <= write_data;
    end

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;

        @(posedge clk);
        rst_n = 1;

        // Write data to address 10
        @(posedge clk);
        address = 15'd10;
        write_data = 16'hABCD;
        write_req = 1;
        @(posedge clk);
        write_req = 0;

        // Wait a few cycles
        repeat (5) @(posedge clk);

        // Read back data from address 10
        @(posedge clk);
        address = 15'd10;
        read_req = 1;
        @(posedge clk);
        read_req = 0;

        // Wait a few cycles
        repeat (5) @(posedge clk);

        // Display results
        $display("Read Data = %h, Expected = ABCD", read_data);

        $finish;
    end

endmodule

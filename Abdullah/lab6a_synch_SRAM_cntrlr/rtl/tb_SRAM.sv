`timescale 1ns/1ps

module tb_SRAM;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Inputs to Top_SRAM
    logic        read_req;
    logic        write_req;
    logic [14:0] address;
    logic [15:0] write_data;

    // Outputs from Top_SRAM
    logic [15:0] read_data;
    logic        ready;

    // Instantiate the Top module
    Top_SRAM dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .read_req   (read_req),
        .write_req  (write_req),
        .address    (address),
        .write_data (write_data),
        .read_data  (read_data),
        .ready      (ready)
    );

    // Clock generation (10 ns period → 100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize signals
        rst_n      = 0;
        read_req   = 0;
        write_req  = 0;
        address    = 0;
        write_data = 16'h0000;

        // Apply reset
        #20;
        rst_n = 1;

        // --------------------------
        // WRITE operation
        // --------------------------
        @(posedge clk);
        address    = 15'd10;
        write_data = 16'hABCD;
        write_req  = 1;

        @(posedge clk);
        write_req = 0;   // deassert request

        wait (ready);    // wait until controller finishes
        @(posedge clk);

        // --------------------------
        // READ operation
        // --------------------------
        @(posedge clk);
        address  = 15'd10;
        read_req = 1;

        @(posedge clk);
        read_req = 0;

        wait (ready);    // wait until controller finishes
        @(posedge clk);

        // Display result
        $display("Read data from address %0d = 0x%0h", address, read_data);

        // --------------------------
        // Extra test: write and read at another address
        // --------------------------
        @(posedge clk);
        address    = 15'd11;
        write_data = 16'h1234;
        write_req  = 1;

        @(posedge clk);
        write_req = 0;

        wait (ready);
        @(posedge clk);

        // Read back from address 20
        @(posedge clk);
        address  = 15'd11;
        read_req = 1;

        @(posedge clk);
        read_req = 0;

        wait (ready);
        @(posedge clk);

        $display("Read data from address %0d = 0x%0h", address, read_data);
		
		 // Read back from address 20
        @(posedge clk);
        address  = 15'd15;
        read_req = 1;

        @(posedge clk);
        read_req = 0;

        wait (ready);
        // Finish simulation
        #50;
        $finish;
    end

endmodule

//--------------DESCRIPTION--------------
// This is a testbench for the FIFO module.
// The testbench generates random data and writes it to the FIFO, 
// then reads it back and compares the results.
//---------------------------------------

`timescale 1ns/1ps

module FIFO_tb();

    parameter DSIZE = 8; // Data bus size
    parameter ASIZE = 3; // Address bus size
    parameter DEPTH = 1 << ASIZE; // FIFO depth

    reg  [DSIZE-1:0] wdata;   // Input data
    wire [DSIZE-1:0] rdata;   // Output data
    wire wfull, rempty;       // Write full and read empty flags
    reg  winc, rinc, wclk, rclk, wrst_n, rrst_n; // Control + Clocks

    // Instantiate FIFO
    FIFO #(DSIZE, ASIZE) fifo (
        .rdata(rdata), 
        .wdata(wdata),
        .wfull(wfull),
        .rempty(rempty),
        .winc(winc), 
        .rinc(rinc), 
        .wclk(wclk), 
        .rclk(rclk), 
        .wrst_n(wrst_n), 
        .rrst_n(rrst_n)
    );

    integer i;
    integer seed = 1;
    reg [DSIZE-1:0] expected_mem [0:DEPTH*2]; // store expected values
    integer wr_ptr = 0, rd_ptr = 0;

    // Generate write clock (fast)
    always #5 wclk = ~wclk;
    // Generate read clock (slow)
    always #10 rclk = ~rclk;

    initial begin
        // Initialize
        wclk = 0;
        rclk = 0;
        wrst_n = 0;
        rrst_n = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;

        // Apply reset properly
        #25 wrst_n = 1; 
        #25 rrst_n = 1; 

        // TEST CASE 1: Write and Read back
        $display("---- TEST 1: Write & Read back ----");
        fork
            begin : WRITE_PROC
                for (i = 0; i < 8; i = i + 1) begin
                    @(posedge wclk);
                    if (!wfull) begin
                        wdata = $random(seed) % 256;
                        winc  = 1;
                        expected_mem[wr_ptr] = wdata;
                        wr_ptr++;
                    end
                end
                @(posedge wclk); winc = 0;
            end

            begin : READ_PROC
                repeat (12) begin
                    @(posedge rclk);
                    if (!rempty) begin
                        rinc = 1;
                        if (rdata !== expected_mem[rd_ptr]) begin
                            $display("ERROR: Expected %0d, Got %0d at time %0t", expected_mem[rd_ptr], rdata, $time);
                        end else begin
                            $display("PASS: Data %0d read correctly at time %0t", rdata, $time);
                        end
                        rd_ptr++;
                    end else rinc = 0;
                end
                rinc = 0;
            end
        join

        // TEST CASE 2: Fill FIFO completely
        $display("---- TEST 2: FIFO FULL condition ----");
        for (i = 0; i < DEPTH+2; i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random(seed) % 256;
                winc  = 1;
                $display("Writing %0d at time %0t", wdata, $time);
            end else begin
                $display("FIFO FULL at time %0t, cannot write", $time);
                winc = 0;
            end
        end
        winc = 0;

        // TEST CASE 3: Read until FIFO empty
        $display("---- TEST 3: FIFO EMPTY condition ----");
        repeat (DEPTH+2) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
                $display("Reading %0d at time %0t", rdata, $time);
            end else begin
                rinc = 0;
                $display("FIFO EMPTY at time %0t, cannot read", $time);
            end
        end

        $finish;
    end
endmodule


//----------------------------EXPLANATION-----------------------------------------------
// The testbench for the FIFO module generates random data and writes it to the FIFO,
// then reads it back and compares the results. The testbench includes three test cases:
// 1. Write data and read it back.
// 2. Write data to make the FIFO full and try to write more data.
// 3. Read data from an empty FIFO and try to read more data. The testbench uses
// clock signals for writing and reading, and includes reset signals to initialize
// the FIFO. The testbench finishes after running the test cases.
//--------------------------------------------------------------------------------------

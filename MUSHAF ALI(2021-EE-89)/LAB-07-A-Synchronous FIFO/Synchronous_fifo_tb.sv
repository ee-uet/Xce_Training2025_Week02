`timescale 1ns/1ps

module tb_sync_fifo;

    // Parameters
    parameter DEPTH = 21;
    parameter DATA_WIDTH = 8;

    // Signals
    logic clk;
    logic rst;
    logic write_enable;
    logic read_enable;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic fifo_empty, fifo_full;
    logic fifo_almost_full, fifo_almost_empty;

    // Instantiate FIFO
    sync_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_in(data_in),
        .data_out(data_out),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .fifo_almost_full(fifo_almost_full),
        .fifo_almost_empty(fifo_almost_empty)
    );

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        write_enable = 0;
        read_enable = 0;
        data_in = 0;
        #20;
        rst = 0;

        // Write 10 random data
        repeat (10) begin
            @(posedge clk);
            write_enable = 1;
            data_in = $random % 256;
        end
        write_enable = 0;

        // Read 5 data
        repeat (5) begin
            @(posedge clk);
            read_enable = 1;
        end
        read_enable = 0;

        // Simultaneous write/read 8 times
        repeat (8) begin
            @(posedge clk);
            write_enable = 1;
            read_enable = 1;
            data_in = $random % 256;
        end
        write_enable = 0;
        read_enable = 0;

        // Fill FIFO to near full to test almost full
        repeat (DEPTH) begin
            @(posedge clk);
            if(!fifo_full) begin
                write_enable = 1;
                data_in = $random % 256;
            end else begin
                write_enable = 0;
            end
        end

        write_enable = 0;

        // Empty FIFO completely to test almost empty
        repeat (DEPTH) begin
            @(posedge clk);
            if(!fifo_empty) begin
                read_enable = 1;
            end else begin
                read_enable = 0;
            end
        end

        read_enable = 0;

        // Finish
        #50;
        $finish;
    end

    // Monitor signals
    initial begin
        $display("Time\tclk\trst\twe\tre\tdata_in\tdata_out\tempty\tfull\talmost_full\talmost_empty");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%0d\t%0d\t%b\t%b\t%b\t%b",
                 $time, clk, rst, write_enable, read_enable, data_in, data_out,
                 fifo_empty, fifo_full, fifo_almost_full, fifo_almost_empty);
    end

endmodule

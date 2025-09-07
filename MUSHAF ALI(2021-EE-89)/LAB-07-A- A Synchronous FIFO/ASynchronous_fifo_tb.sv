`timescale 1ns/1ps

module tb_Async_fifo;

    // Parameters
    localparam DEPTH = 8;
    localparam DATA_WIDTH = 8;

    // Testbench signals
    logic write_enable;
    logic read_enable;
    logic clk_wr;
    logic clk_rd;
    logic rst;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic fifo_empty, fifo_full, fifo_almost_full, fifo_almost_empty;

    // Clock generation
    initial clk_wr = 0;
    initial clk_rd = 0;
    always #5 clk_wr = ~clk_wr;  // 100 MHz write clock
    always #7 clk_rd = ~clk_rd;  // 71.4 MHz read clock

    // Instantiate FIFO
    Async_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .write_enable(write_enable),
        .read_enable(read_enable),
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .fifo_almost_full(fifo_almost_full),
        .fifo_almost_empty(fifo_almost_empty)
    );

    // Stimulus
    initial begin
        // Initialize signals
        rst = 1;
        write_enable = 0;
        read_enable = 0;
        data_in = 0;

        // Hold reset
        #20;
        rst = 0;

        // Fill FIFO
        repeat(DEPTH) begin
            @(posedge clk_wr);
            write_enable = 1;
            data_in = $random;
        end
        @(posedge clk_wr);
        write_enable = 0;

        // Check FIFO full condition
        $display("FIFO full? %b", fifo_full);
        $display("FIFO almost full? %b", fifo_almost_full);

        // Read half of FIFO
        repeat(DEPTH/2) begin
            @(posedge clk_rd);
            read_enable = 1;
        end
        @(posedge clk_rd);
        read_enable = 0;

        // Check almost empty
        $display("FIFO empty? %b", fifo_empty);
        $display("FIFO almost empty? %b", fifo_almost_empty);

        // Continue writes and reads randomly
        repeat(20) begin
            @(posedge clk_wr);
            write_enable = $urandom_range(0,1);
            data_in = $random;
            @(posedge clk_rd);
            read_enable = $urandom_range(0,1);
        end

        // Final status
        $display("Final FIFO status:");
        $display("FIFO full: %b", fifo_full);
        $display("FIFO empty: %b", fifo_empty);
        $display("FIFO almost full: %b", fifo_almost_full);
        $display("FIFO almost empty: %b", fifo_almost_empty);

        $stop;
    end

endmodule
`timescale 1ns/1ps

module tb_Async_fifo;

    // Parameters
    localparam DEPTH = 8;
    localparam DATA_WIDTH = 8;

    // Testbench signals
    logic write_enable;
    logic read_enable;
    logic clk_wr;
    logic clk_rd;
    logic rst;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic fifo_empty, fifo_full, fifo_almost_full, fifo_almost_empty;

    // Clock generation
    initial clk_wr = 0;
    initial clk_rd = 0;
    always #5 clk_wr = ~clk_wr;  // 100 MHz write clock
    always #7 clk_rd = ~clk_rd;  // 71.4 MHz read clock

    // Instantiate FIFO
    Async_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .write_enable(write_enable),
        .read_enable(read_enable),
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .fifo_almost_full(fifo_almost_full),
        .fifo_almost_empty(fifo_almost_empty)
    );

    // Stimulus
    initial begin
        // Initialize signals
        rst = 1;
        write_enable = 0;
        read_enable = 0;
        data_in = 0;

        // Hold reset
        #20;
        rst = 0;

        // Fill FIFO
        repeat(DEPTH) begin
            @(posedge clk_wr);
            write_enable = 1;
            data_in = $random;
        end
        @(posedge clk_wr);
        write_enable = 0;

        // Check FIFO full condition
        $display("FIFO full? %b", fifo_full);
        $display("FIFO almost full? %b", fifo_almost_full);

        // Read half of FIFO
        repeat(DEPTH/2) begin
            @(posedge clk_rd);
            read_enable = 1;
        end
        @(posedge clk_rd);
        read_enable = 0;

        // Check almost empty
        $display("FIFO empty? %b", fifo_empty);
        $display("FIFO almost empty? %b", fifo_almost_empty);

        // Continue writes and reads randomly
        repeat(20) begin
            @(posedge clk_wr);
            write_enable = $urandom_range(0,1);
            data_in = $random;
            @(posedge clk_rd);
            read_enable = $urandom_range(0,1);
        end

        // Final status
        $display("Final FIFO status:");
        $display("FIFO full: %b", fifo_full);
        $display("FIFO empty: %b", fifo_empty);
        $display("FIFO almost full: %b", fifo_almost_full);
        $display("FIFO almost empty: %b", fifo_almost_empty);

        $stop;
    end

endmodule

`timescale 1ns/1ps

module tb_sync_fifo;

    // Parameters
    localparam int DATA_WIDTH = 8;
    localparam int FIFO_DEPTH = 16;

    // DUT signals
    logic                    clk;
    logic                    rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wr_data;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rd_data;
    logic                    full;
    logic                    empty;
    logic                    almost_full;
    logic                    almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // Instantiate DUT
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(count)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // Stimulus (trimmed)
    initial begin
        // Initialize
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = '0;

        // Reset
        #20;
        rst_n = 1;
        #10;

        // --- Write 5 values into FIFO ---
        for (int i = 0; i < 5; i++) begin
            @(posedge clk);
            wr_en   = 1;
            wr_data = i + 8'hA0; // arbitrary data
        end
        @(posedge clk);
        wr_en = 0;

        // --- Read 3 values from FIFO ---
        for (int i = 0; i < 3; i++) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        // --- Stop simulation ---
        #50;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("T=%0t | wr_en=%0b wr_data=%h | rd_en=%0b rd_data=%h | count=%0d | full=%0b empty=%0b af=%0b ae=%0b",
                 $time, wr_en, wr_data, rd_en, rd_data, count, full, empty, almost_full, almost_empty);
    end

endmodule

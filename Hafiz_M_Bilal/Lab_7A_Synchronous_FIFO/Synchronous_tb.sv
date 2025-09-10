module Synchronous_tb;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    logic clk, rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty, almost_full, almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // DUT
    Synchronous_FIFO #(
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
    always #5 clk = ~clk;  // 100 MHz

    // Stimulus
    initial begin
        $display("Starting FIFO test...");
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        #20;
        rst_n = 1;

        // Write 10 values
        repeat (10) begin
            @(posedge clk);
            wr_en <= 1;
            wr_data <= $urandom_range(0, 255);
        end
        @(posedge clk);
        wr_en <= 0;

        // Read 5 values
        repeat (5) begin
            @(posedge clk);
            rd_en <= 1;
        end
        @(posedge clk);
        rd_en <= 0;

        // Write again until full
        repeat (FIFO_DEPTH) begin
            @(posedge clk);
            wr_en <= !full;
            wr_data <= $random;
        end
        wr_en <= 0;

        // Read until empty
        while (!empty) begin
            @(posedge clk);
            rd_en <= 1;
        end
        rd_en <= 0;

        $display("FIFO test completed.");
        $stop;
    end

endmodule

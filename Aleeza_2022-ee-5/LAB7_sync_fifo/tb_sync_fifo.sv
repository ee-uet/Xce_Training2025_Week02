module tb_sync_fifo;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 8;

    // DUT signals
    logic clk;
    logic rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty, almost_full, almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // DUT instance
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(FIFO_DEPTH-2),
        .ALMOST_EMPTY_THRESH(2)
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

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Init
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Reset pulse
        #12 rst_n = 1;
        $display("[%0t] Reset done",$time);

        // -------------------------
        // Write until FIFO full
        // -------------------------
        repeat (FIFO_DEPTH) begin
            @(posedge clk);
            wr_en = 1;
            wr_data = $random % 256;
            $display("[%0t] Writing data = %0d, count=%0d",$time, wr_data, count);
        end
        @(posedge clk) wr_en = 0;

        // -------------------------
        // Try writing when FULL
        // -------------------------
        @(posedge clk);
        wr_en = 1; wr_data = 99;
        $display("[%0t] Attempt to write when full, data=%0d",$time, wr_data);
        @(posedge clk) wr_en = 0;

        // -------------------------
        // Read until FIFO empty
        // -------------------------
        repeat (FIFO_DEPTH) begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk); // wait one cycle for rd_data
            $display("[%0t] Read data = %0d, count=%0d",$time, rd_data, count);
        end
        @(posedge clk) rd_en = 0;

        // -------------------------
        // Simultaneous Read + Write
        // -------------------------
        @(posedge clk);
        wr_en = 1; wr_data = 55;
        rd_en = 1;
        $display("[%0t] Simultaneous R/W attempt",$time);
        @(posedge clk);
        wr_en = 0; rd_en = 0;

        // -------------------------
        // Finish
        // -------------------------
        #20;
        $display("Simulation complete.");
        $finish;
    end

endmodule


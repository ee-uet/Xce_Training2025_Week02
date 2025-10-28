module SyncFIFO_tb;

    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

    logic clk, rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty, almost_full, almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // Reference FIFO
    reg [DATA_WIDTH-1:0] ref_fifo [0:FIFO_DEPTH-1];
    integer head, tail, size;
    integer i;

    // DUT instantiation
    SyncFIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) DUT (
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

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Testbench
    initial begin
        rst_n = 0; wr_en = 0; rd_en = 0; wr_data = 0;
        head = 0; tail = 0; size = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // --- Write 8 values ---
        $display("\n[TEST] Writing 8 values");
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            if (!full) begin
                wr_en = 1;
                wr_data = $urandom_range(0,255);
                ref_fifo[tail] = wr_data;
                tail = (tail + 1) % FIFO_DEPTH;
                size = size + 1;
                $display("WRITE: %0h (size=%0d)", wr_data, size);
            end else wr_en = 0;
        end
        @(posedge clk); wr_en = 0;

        // --- Read 4 values ---
        $display("\n[TEST] Reading 4 values");
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            if (!empty) begin
                rd_en = 1;
                @(posedge clk);
                rd_en = 0;
                if (rd_data !== ref_fifo[head])
                    $display("READ MISMATCH! Expected %0h, Got %0h", ref_fifo[head], rd_data);
                else
                    $display("READ: %0h (size=%0d)", rd_data, size);
                head = (head + 1) % FIFO_DEPTH;
                size = size - 1;
            end
        end

        // --- Mixed read/write ---
        $display("\n[TEST] Mixed read/write");
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            wr_en = ($urandom_range(0,1) && !full);
            rd_en = ($urandom_range(0,1) && !empty);

            if (wr_en) begin
                wr_data = $urandom_range(0,255);
                ref_fifo[tail] = wr_data;
                tail = (tail + 1) % FIFO_DEPTH;
                size = size + 1;
                $display("MIXED-WRITE: %0h (size=%0d)", wr_data, size);
            end

            if (rd_en) begin
                @(posedge clk);
                rd_en = 0;
                if (rd_data !== ref_fifo[head])
                    $display("MIXED-READ MISMATCH! Expected %0h, Got %0h", ref_fifo[head], rd_data);
                else
                    $display("MIXED-READ: %0h (size=%0d)", rd_data, size);
                head = (head + 1) % FIFO_DEPTH;
                size = size - 1;
            end
        end

        $display("\n[TEST] Completed. Final size=%0d", size);
        $finish;
    end

endmodule

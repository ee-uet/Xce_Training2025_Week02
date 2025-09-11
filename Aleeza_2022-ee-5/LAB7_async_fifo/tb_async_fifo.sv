module tb_async_fifo;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

    // DUT signals
    logic wr_clk, rd_clk, rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty;

    // DUT Instance
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    // --------------------------
    // Clock Generation
    // --------------------------
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;  // 100 MHz write clock
    end

    initial begin
        rd_clk = 0;
        forever #12 rd_clk = ~rd_clk; // ~41.6 MHz read clock
    end

    // --------------------------
    // Test Procedure
    // --------------------------
    initial begin
        // Init
        wr_en = 0; rd_en = 0; wr_data = 0;
        rst_n = 0;

        // Reset
        #30 rst_n = 1;
        $display("[%0t] Reset released",$time);

        // --------------------------
        // Write some data
        // --------------------------
        repeat (8) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en = 1;
                wr_data = $random % 256;
                $display("[%0t] WRITE: data=%0d", $time, wr_data);
            end
        end
        @(posedge wr_clk) wr_en = 0;

        // --------------------------
        // Read some data
        // --------------------------
        repeat (4) begin
            @(posedge rd_clk);
            if (!empty) begin
                rd_en = 1;
                @(posedge rd_clk); // one cycle latency
                $display("[%0t] READ: data=%0d", $time, rd_data);
            end
        end
        @(posedge rd_clk) rd_en = 0;

        // --------------------------
        // Mixed operations
        // --------------------------
        repeat (20) begin
            @(posedge wr_clk);
            if (!full && ($urandom % 2)) begin
                wr_en = 1;
                wr_data = $random % 256;
                $display("[%0t] WRITE: data=%0d", $time, wr_data);
            end else begin
                wr_en = 0;
            end

            @(posedge rd_clk);
            if (!empty && ($urandom % 2)) begin
                rd_en = 1;
                @(posedge rd_clk);
                $display("[%0t] READ: data=%0d", $time, rd_data);
            end else begin
                rd_en = 0;
            end
        end

        // Finish
        #100;
        $display("Simulation complete.");
        $finish;
    end

endmodule


`timescale 1ns/1ps

module tb_async_fifo;

    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

    logic wr_clk, rd_clk;
    logic wr_rst_n, rd_rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty;

    // DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock generation
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;   // 100 MHz

    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk;   // ~71 MHz

    // Stimulus
    initial begin
        wr_rst_n = 0; rd_rst_n = 0;
        wr_en = 0; rd_en = 0; wr_data = 0;
        #20;
        wr_rst_n = 1; rd_rst_n = 1;

        // Write 10 values
        repeat (10) begin
            @(posedge wr_clk);
            if (!full) begin
                wr_en = 1;
                wr_data = $random;
            end
        end
        wr_en = 0;

        // Read 10 values
        repeat (10) begin
            @(posedge rd_clk);
            if (!empty) rd_en = 1;
            else rd_en = 0;
        end
        rd_en = 0;

        #100 $finish;
    end

    // Debugging prints
    always @(posedge wr_clk)
        if (wr_en && !full)
            $display("[%0t] WRITE: %0h", $time, wr_data);

    always @(posedge rd_clk)
        if (rd_en && !empty)
            $display("[%0t] READ : %0h", $time, rd_data);

endmodule

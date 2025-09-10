`timescale 1ns/1ps

module tb_async_fifo;

    // Parameters
    localparam int DATA_WIDTH = 8;
    localparam int FIFO_DEPTH = 16;

    // DUT signals
    logic                    wr_clk, rd_clk;
    logic                    rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wr_data;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rd_data;
    logic                    full, empty, almost_full, almost_empty;

    // Instantiate DUT
    sync_fifo #(
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
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );

    // Clocks
    initial wr_clk = 0;
    always #5  wr_clk = ~wr_clk;   // 100 MHz write clock

    initial rd_clk = 0;
    always #7  rd_clk = ~rd_clk;   // ~71 MHz read clock

    // Stimulus
    initial begin
        // init
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = '0;

        // reset
        #20;
        rst_n = 1;
        #10;

        // --- Write 8 values into FIFO ---
        for (int i = 0; i < 8; i++) begin
            @(posedge wr_clk);
            wr_en   = 1;
            wr_data = 8'hA0 + i;
        end
        @(posedge wr_clk);
        wr_en = 0;

        // --- Start reading after some delay ---
        #50;
        for (int i = 0; i < 8; i++) begin
            @(posedge rd_clk);
            rd_en = 1;
        end
        @(posedge rd_clk);
        rd_en = 0;

        // stop sim
        #100;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("T=%0t | wr_en=%0b wr_data=%h | rd_en=%0b rd_data=%h | full=%0b empty=%0b af=%0b ae=%0b",
                 $time, wr_en, wr_data, rd_en, rd_data, full, empty, almost_full, almost_empty);
    end

endmodule

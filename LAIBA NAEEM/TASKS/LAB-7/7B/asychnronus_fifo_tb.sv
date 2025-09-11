module tb_async_fifo;

    // Parameters
    localparam int DATA_WIDTH = 8;
    localparam int FIFO_DEPTH = 16;

    // Testbench signals
    logic wr_clk, wr_rst_n;
    logic rd_clk, rd_rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

    // Instantiate DUT
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .wr_clk    (wr_clk),
        .wr_rst_n  (wr_rst_n),
        .wr_en     (wr_en),
        .wr_data   (wr_data),
        .rd_clk    (rd_clk),
        .rd_rst_n  (rd_rst_n),
        .rd_en     (rd_en),
        .rd_data   (rd_data)
    );

    // Clock generation
    always #5 wr_clk = ~wr_clk; // 100 MHz
    always #7 rd_clk = ~rd_clk; // ~71 MHz (asynchronous)

    // Test sequence
    initial begin
        // Initialize
        wr_clk = 0;
        rd_clk = 0;
        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Apply reset
        #20;
        wr_rst_n = 1;
        rd_rst_n = 1;

        // Write data into FIFO
        repeat (10) begin
            @(posedge wr_clk);
            wr_en = 1;
            wr_data = wr_data + 1;
        end
        @(posedge wr_clk);
        wr_en = 0;

        // Read data from FIFO
        repeat (10) begin
            @(posedge rd_clk);
            rd_en = 1;
        end
        @(posedge rd_clk);
        rd_en = 0;

        // Finish simulation
        #50;
        $finish;
    end

endmodule

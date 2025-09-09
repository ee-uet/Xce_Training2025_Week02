
module sync_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;
    localparam ALMOST_FULL_THRESH = 14;
    localparam ALMOST_EMPTY_THRESH = 2;

    
    logic clk, rst_n;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full, empty, almost_full, almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    // Instantiate DUT
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
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
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        rst_n = 0; wr_en = 0; rd_en = 0; wr_data = 0;
        #3;
        rst_n = 1;

        // Write 4 values
        repeat (4) begin
            @(posedge clk);
            wr_en = 1;
            wr_data = $random;
        end
        @(posedge clk);
        wr_en = 0;

        // Read 4 values
        rd_en = 1;
        repeat (5) @(posedge clk);
        
        rd_en = 0;


        
        @(posedge clk);
        $finish;
    end

    

endmodule
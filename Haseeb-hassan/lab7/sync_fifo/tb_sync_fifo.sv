module tb_sync_fifo;
    logic        clk;
    logic        rst_n;
    logic        wr_en;
    logic [7:0]  wr_data;
    logic        rd_en;
    logic [7:0]  rd_data;
    logic        full;
    logic        empty;
    logic        almost_full;
    logic        almost_empty;
    logic [4:0]  count;

    // Instantiate DUT
    sync_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(16),
        .ALMOST_FULL_THRESH(14),
        .ALMOST_EMPTY_THRESH(2)
    ) UUT (
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

    initial begin
        // Initialize
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        
        #20 rst_n = 1;
        #10;
        
        // Test 1: Write some data
        wr_data = 8'hAA;
        wr_en = 1;
        #10 wr_en = 0;
        
        wr_data = 8'hBB;
        wr_en = 1;
        #10 wr_en = 0;
        
        wr_data = 8'hCC;
        wr_en = 1;
        #10 wr_en = 0;
        #10;
        
        // Test 2: Read data back
        rd_en = 1;
        #10 rd_en = 0;
        #10;
        
        rd_en = 1;
        #10 rd_en = 0;
        #10;
        
        // Test 3: Fill to almost full
        repeat(12) begin
            wr_data = wr_data + 1;
            wr_en = 1;
            #10 wr_en = 0;
        end
        #10;
        
        // Test 4: Fill to full
        wr_data = 8'hFF;
        wr_en = 1;
        #10 wr_en = 0;
        #10;
        
        // Test 5: Try write when full
        wr_data = 8'h11;
        wr_en = 1;
        #10 wr_en = 0;
        #10;
        
        // Test 6: Empty the FIFO
        repeat(16) begin
            rd_en = 1;
            #10 rd_en = 0;
        end
        #10;
        
        // Test 7: Try read when empty
        rd_en = 1;
        #10 rd_en = 0;
        #50;
        
        $finish;
    end

endmodule
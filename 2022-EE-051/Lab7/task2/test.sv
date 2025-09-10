module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter ALMOST_EMPTY_THRESHOLD = 2;
    parameter ALMOST_FULL_THRESHOLD  = 14;

    logic wr_clk, rd_clk;
    initial wr_clk = 0;
    initial rd_clk = 0;
    always #5  wr_clk = ~wr_clk;  
    always #7  rd_clk = ~rd_clk;  

    logic rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic empty, almost_empty, full, almost_full;
    logic [$clog2(FIFO_DEPTH):0] count;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)
    ) dut (.*);

initial begin
    rst_n = 0; wr_en = 0; rd_en = 0; wr_data = 0;
    #20;
    rst_n = 1;
    #20;

    wr_data = 1; @(posedge wr_clk); wr_en = 1;
    wr_data = 2; @(posedge wr_clk); wr_en = 1;
    wr_data = 3; @(posedge wr_clk); wr_en = 1;
    @(posedge wr_clk); wr_en = 0;
    #10;
    $display("Count=%0d, full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
             count, full, almost_full, empty, almost_empty);

    // Write up to almost full
    
    for (int i = 4; i <= 14; i=i+1) begin
        wr_data = i;
        @(posedge wr_clk); wr_en = 1;
    end
    @(posedge wr_clk); wr_en = 0;
    #10;
    $display("Count=%0d, full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
             count, full, almost_full, empty, almost_empty);

    // Read 2 items
   
    repeat (2) @(posedge rd_clk) rd_en = 1;
    @(posedge rd_clk); rd_en = 0;
    #10;
    $display("Count=%0d, full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
             count, full, almost_full, empty, almost_empty);

    // Fill FIFO completely
    
    for (int i = 15; i <= 16; i=i+1) begin
        wr_data = i;
        @(posedge wr_clk); wr_en = 1;
    end
    @(posedge wr_clk); wr_en = 0;
    #10;
    $display("Count=%0d, full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
             count, full, almost_full, empty, almost_empty);

    // Read all items

    repeat (FIFO_DEPTH) @(posedge rd_clk) rd_en = 1;
    @(posedge rd_clk); rd_en = 0;
    #10;
    $display("Count=%0d, full=%b, almost_full=%b, empty=%b, almost_empty=%b", 
             count, full, almost_full, empty, almost_empty);

    $stop;
end
endmodule
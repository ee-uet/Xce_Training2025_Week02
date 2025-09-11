module tb_sync_fifo;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter ALMOST_EMPTY_THRESHOLD = 2;
    parameter ALMOST_FULL_THRESHOLD  = 14;

    // Signals
    logic clk;
    logic rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic empty, almost_empty, full, almost_full;
    logic [$clog2(FIFO_DEPTH):0] count;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)
    ) fifo_inst (.*);

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  

    initial begin
        // Reset
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        #20;
        rst_n = 1;

        // Case 1: Write 1 element
        wr_en = 1; wr_data = 8'hA1; #10;
        wr_en = 0; #10;
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);

        // Case 2: Write 1 more element (count=2)
        wr_en = 1; wr_data = 8'hB2; #10;
        wr_en = 0; #10;
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);

        // Case 3: Fill to 14 elements (almost_full)
        repeat (12) begin
            wr_en = 1; wr_data = $random; #10; wr_en=0; #10;
        end
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);

        // Case 4: Write 2 more (count=16, full)
        wr_en = 1; wr_data = 8'hFF; #10; wr_en=0; #10;
        wr_en = 1; wr_data = 8'hEE; #10; wr_en=0; #10;
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);

        // Case 5: Read 2 elements (count=14, almost_full)
        rd_en = 1; #10; rd_en=0; #10;
        rd_en = 1; #10; rd_en=0; #10;
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);

        // Case 6: Read all to empty
        rd_en = 1;
        repeat (14) #10;
        rd_en = 0;
        $display("Count=%0d | empty=%b, almost_empty=%b, almost_full=%b, full=%b", count, empty, almost_empty, almost_full, full);
        $stop;
    end

endmodule

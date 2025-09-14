module sync_fifo_tb;

    parameter int DATA_WIDTH = 8;
    parameter int FIFO_DEPTH = 4;
    parameter int ALMOST_FULL_THRESH = 3;
    parameter int ALMOST_EMPTY_THRESH = 1;

    
    logic clk;
    logic rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;

    
    sync_fifo #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
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

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        
        rst_n = 1'b0;

        wr_en = 1'b0;
        rd_en = 1'b0;
        wr_data = 8'b0;
        
        #10;
        
        rst_n = 1'b1;

        @(posedge clk);
        
        // write to fifo
        wr_en = 1'b1;
        wr_data = 8'd255;
        @(posedge clk);
        wr_data = 8'd128;
        @(posedge clk);
        wr_data = 8'd64;
        @(posedge clk);
        wr_data = 8'd32;
        @(posedge clk);

        //trying to write when fifo full
        wr_data = 8'd1;
        @(posedge clk);
        wr_en = 1'b0;
        // read from fifo
        rd_en = 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);




        $stop;
    end

endmodule

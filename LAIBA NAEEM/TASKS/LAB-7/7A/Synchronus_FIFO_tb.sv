module sync_fifo_tb();
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

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

    // Instantiate FIFO
    sync_fifo dut(.*);

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; 

   initial begin
    rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;
    @(posedge clk);  
    rst_n = 1;       
    @(posedge clk);
    
    // Write example
    wr_data = 8'b00110011;
    wr_en = 1;
    @(posedge clk);
    wr_en = 0;
    
    // Read example
    @(posedge clk);
    rd_en = 1;
    @(posedge clk);
    rd_en = 0;
end

    always @(posedge clk) begin
        $display("Time=%0t | rd_data=%0b | full=%b | empty=%b | count=%0d",
                 $time, rd_data, full, empty, count);
    end
endmodule

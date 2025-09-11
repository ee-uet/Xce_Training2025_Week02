module sync_fifo_tb;

  // Parameters
  parameter DATA_WIDTH = 16;
  parameter FIFO_DEPTH = 8;
 
  logic clk, reset;
  logic wr_en, rd_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty, almost_full, almost_empty;
  logic [$clog2(FIFO_DEPTH+1)-1:0] count;
 
  sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
    .clk(clk),
    .reset(reset),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty),
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .count(count)
  );
 
  always #5 clk = ~clk;
 
  initial begin
  
    clk   = 0;
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;
 
    #10 reset = 0;
   
    // Write some data (6 words)
    for (int i = 0; i < 6; i++) begin
      @(posedge clk);
      wr_en   = 1;
      rd_en   = 0;
      data_in = $urandom_range(0, 1000);


    @(posedge clk);
    wr_en = 0;

   
    // Read 3 words
    for (int j = 0; j < 3; j++) begin
      @(posedge clk);
      rd_en = 1;
      wr_en = 0;
    end

    @(posedge clk);
    rd_en = 0;
 
    // Fill FIFO until full
    while (!full) begin
      @(posedge clk);
      wr_en   = 1;
      rd_en   = 0;
      data_in = $urandom_range(0, 1000);

    end

    @(posedge clk);
    wr_en = 0;
    $display("[%0t] FIFO FULL reached, count=%0d", $time, count);

  
    // Empty FIFO completely
    while (!empty) begin
      @(posedge clk);
      rd_en = 1;
      wr_en = 0;
    end

    @(posedge clk);
    rd_en = 0;
  
    #20;
    $finish;
  end

endmodule

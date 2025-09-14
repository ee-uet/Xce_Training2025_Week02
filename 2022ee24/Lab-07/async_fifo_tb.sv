module async_fifo_tb;
  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;
  
  logic wclk, wrst_n;
  logic rclk, rrst_n;
  logic w_en, r_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty;
  
  // Instantiate the FIFO
  asynchronous_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );
  
  // Write clock (100MHz)
  always #5 wclk = ~wclk;
  
  // Read clock (75MHz)
  always #6.67 rclk = ~rclk;
  
  initial begin
    // Initialize
    wclk = 0;
    rclk = 0;
    wrst_n = 0;
    rrst_n = 0;
    w_en = 0;
    r_en = 0;
    data_in = 0;
    
    // Release reset
    #20;
    wrst_n = 1;
    rrst_n = 1;
    #10;
    
    $display("Test 1: Write 4 values");
    // Write some data
    for (int i = 0; i < 4; i++) begin
      @(posedge wclk);
      w_en = 1;
      data_in = i + 1; // Write 1, 2, 3, 4
      @(posedge wclk);
      w_en = 0;
    end
    
    #20;
    $display("Test 2: Read 4 values");
    // Read the data back
    for (int i = 0; i < 4; i++) begin
      @(posedge rclk);
      r_en = 1;
      @(posedge rclk);
      r_en = 0;
      $display("Read data: %d", data_out);
    end
    
    #20;
    $display("Test 3: Fill FIFO to full");
    // Fill the FIFO
    for (int i = 0; i < 10; i++) begin
      @(posedge wclk);
      w_en = 1;
      data_in = i + 10;
      @(posedge wclk);
      w_en = 0;
      if (full) begin
        $display("FIFO is full!");
        break;
      end
    end
    
    #20;
    $display("Test 4: Empty FIFO");
    // Empty the FIFO
    for (int i = 0; i < 10; i++) begin
      @(posedge rclk);
      r_en = 1;
      @(posedge rclk);
      r_en = 0;
      $display("Read data: %d", data_out);
      if (empty) begin
        $display("FIFO is empty!");
        break;
      end
    end
    
    #50;
    $display("Test completed");
    $finish;
  end
endmodule
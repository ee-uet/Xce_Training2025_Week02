module tb_binary_to_bcd;

  logic clk, rst_n;
  logic [7:0]  binary_in;
  logic [11:0] bcd_out;

  // DUT instance
  binary_to_bcd dut (
    .binary_in(binary_in),
    .bcd_out  (bcd_out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  // Reset
  initial begin
    rst_n = 0;
    #12 rst_n = 1;
  end

  
  initial begin
    binary_in = 8'd0;   #10;
    binary_in = 8'd9;   #10;
    binary_in = 8'd45;  #10;
    binary_in = 8'd99;  #10;
    binary_in = 8'd123; #10;
    binary_in = 8'd255; #10;

    $stop;
  end

endmodule

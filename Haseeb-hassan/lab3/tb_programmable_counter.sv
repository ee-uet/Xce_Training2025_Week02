`timescale 1ns/1ps

module tb_programmable_counter;

  logic clk;
  logic rst_n;
  logic load;
  logic enable;
  logic up_down;
  logic [7:0] load_value;
  logic [7:0] max_count;
  logic [7:0] count;
  logic tc;
  logic zero;

  // clock: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT
  programmable_counter dut (
    .clk(clk),
    .rst_n(rst_n),
    .load(load),
    .enable(enable),
    .up_down(up_down),
    .load_value(load_value),
    .max_count(max_count),
    .count(count),
    .tc(tc),
    .zero(zero)
  );

  // stimulus
  initial begin
    // init
    rst_n      = 0;
    load       = 0;
    enable     = 0;
    up_down    = 1;
    load_value = 8'd0;
    max_count  = 8'd10;

    #20 rst_n = 1;     // release reset

    // load value = 5
    load       = 1;
    load_value = 8'd5;
    #10 load   = 0;

    // count up
    enable = 1; up_down = 1;
    #200;

    // count down
    up_down = 0;
    #200;

    // stop counting
    enable = 0;
    #50;

    $finish;
  end

endmodule

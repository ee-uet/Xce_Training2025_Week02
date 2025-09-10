`timescale 1ns/1ps

module tb_programe_able_updown_counter;

  // Testbench signals
  logic clk, rst, enable, updown, load;
  logic [7:0] load_data;
  logic [7:0] upper_limit, lower_limit;
  logic terminal_count, zero_count;
  logic [7:0] count;

  // DUT instantiation
  programe_able_updown_counter dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .updown(updown),
    .load(load),
    .load_data(load_data),
    .upper_limit(upper_limit),
    .lower_limit(lower_limit),
    .terminal_count(terminal_count),
    .zero_count(zero_count),
    .count(count)
  );

  // Clock generation (10ns period)
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    $display("==== TEST START ====");
    clk = 0;
    rst = 1;
    enable = 0;
    updown = 1;
    load = 0;
    load_data = 8'd0;
    upper_limit = 8'd10;
    lower_limit = 8'd3;

    // Apply reset
    #10 rst = 0;
    $display("[%0t] Reset done, count = %0d", $time, count);

    // Load value into counter
    load_data = 8'd5;
    load = 1;
    #10 load = 0;
    $display("[%0t] Load 5, count = %0d", $time, count);

    // Enable UP counting
    enable = 1;
    updown = 1;
    repeat (8) @(posedge clk); // count up till upper_limit
    $display("[%0t] After UP count, count = %0d, terminal_count = %b", $time, count, terminal_count);

    // Change to DOWN counting
    updown = 0;
    repeat (8) @(posedge clk); // count down till lower_limit
    $display("[%0t] After DOWN count, count = %0d, terminal_count = %b", $time, count, terminal_count);

    // Dynamic change of upper limit
    upper_limit = 8'd6;
    updown = 1;
    repeat (5) @(posedge clk);
    $display("[%0t] Dynamic Upper Limit Applied, count = %0d", $time, count);

    // Dynamic change of lower limit
    lower_limit = 8'd4;
    updown = 0;
    repeat (5) @(posedge clk);
    $display("[%0t] Dynamic Lower Limit Applied, count = %0d", $time, count);

    // Zero check
    load_data = 8'd0;
    load = 1;
    #10 load = 0;
    $display("[%0t] Loaded 0, zero_count = %b", $time, zero_count);

    $display("==== TEST END ====");
    $stop;
  end

endmodule

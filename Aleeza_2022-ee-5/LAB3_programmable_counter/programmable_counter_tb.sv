module programmable_counter_tb;

  // Testbench signals
  logic        clk;
  logic        rst;
  logic        load;
  logic        enable;
  logic        up_down;
  logic  [7:0] load_value;
  logic  [7:0] max_count;
  logic  [7:0] count;
  logic        tc;
  logic        zero;

  // DUT instantiation
  programmable_counter dut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .enable(enable),
    .up_down(up_down),
    .load_value(load_value),
    .max_count(max_count),
    .count(count),
    .tc(tc),
    .zero(zero)
  );

  // Clock generation: 10ns period (100MHz)
  always #5 clk = ~clk;

  initial begin
    // Initial values
    clk = 1;
    rst = 1;
    load = 0;
    enable = 0;
    up_down = 1;       // default up
    load_value = 0;
    max_count = 10;

    // Reset pulse
    #12 rst = 0;

    // Test 1: Load value 3 and count UP to max_count=10
    load_value = 3;
    load = 1;
    #10 load = 0;
    enable = 1;
    up_down = 1;   // up counting
    #100;

    // Test 2: Now change to DOWN counting from current value
    up_down = 0;
    #100;

    // Test 3: Reload with value 7 and change max_count mid-way
    enable = 0;
    load_value = 7;
    load = 1;
    #10 load = 0;
    enable = 1;
    up_down = 1;
    #30 max_count = 5;   // Change max_count during operation
    #50;

    // End simulation
    $finish;
  end

  // Monitor values
  initial begin
    $monitor("Time=%0t | rst=%b load=%b en=%b up_down=%b load_val=%0d max=%0d count=%0d tc=%b zero=%b",
              $time, rst, load, enable, up_down, load_value, max_count, count, tc, zero);
  end

endmodule


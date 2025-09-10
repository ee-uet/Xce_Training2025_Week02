module fsm_vendingmachine_specialcase_tb;
  logic clk, rst;
  logic coin_5, coin_10, coin_25, coin_return;
  logic dispense_item, return_5, return_10, return_25;
  logic [5:0] amount_display;

  // DUT instantiation
  fsm_vendingmachine dut (
    .clk(clk),
    .rst(rst),
    .coin_5(coin_5),
    .coin_10(coin_10),
    .coin_25(coin_25),
    .coin_return(coin_return),
    .dispense_item(dispense_item),
    .return_5(return_5),
    .return_10(return_10),
    .return_25(return_25),
    .amount_display(amount_display)
  );

  // Clock generator
  initial clk = 0;
  always #5 clk = ~clk;  // 10ns period

  // Stimulus
  initial begin
    // Init signals
    rst = 0;
    coin_5 = 0; coin_10 = 0; coin_25 = 0; coin_return = 0;
    #20;
    rst = 1;
    #20;
    rst=0;

    // Insert two 10-cent coins -> reach COIN_20
    @(posedge clk); coin_10 = 1;
    @(posedge clk); coin_10 = 1;  // first 10
  
    // Request coin return
    @(posedge clk); coin_10=0;coin_return = 1;
    @(posedge clk); coin_return = 0;

    // Wait few cycles to observe both returns
    repeat(5) @(posedge clk);

    $finish;
  end

  // Monitor outputs
  initial begin
    $display("Time | State Outputs | Dispense | Ret5 Ret10 Ret25 | Amount");
    $monitor("%0t | Disp=%b | R5=%b R10=%b R25=%b | Amount=%0d",
              $time, dispense_item, return_5, return_10, return_25, amount_display);
  end

endmodule

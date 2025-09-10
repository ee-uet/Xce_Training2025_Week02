`timescale 1ns/1ps

module tb_vend_seq;

  // Clock & DUT I/O
  logic clk = 0, rst_n = 0;
  logic coin_5 = 0, coin_10 = 0, coin_25 = 0, coin_return = 0;
  logic dispense_item, return_5, return_10, return_25;
  logic [5:0] amount_display;

  // 10 ns clock
  always #5 clk = ~clk;

  // DUT
  vending_machine dut (
    .clk(clk), .rst_n(rst_n),
    .coin_5(coin_5), .coin_10(coin_10), .coin_25(coin_25), .coin_return(coin_return),
    .dispense_item(dispense_item), .return_5(return_5), .return_10(return_10), .return_25(return_25),
    .amount_display(amount_display)
  );

  // Pulse one coin for EXACTLY 1 clock, then give 1 idle clock
  task automatic pulse_coin(input bit c5, c10, c25, input string label);
    // assert on negedge, sample on next posedge (Mealy outputs valid here)
    @(negedge clk);
    coin_5  = c5; coin_10 = c10; coin_25 = c25;
    @(posedge clk);
    $display("[%0t] %-22s | disp=%0d di=%0b r5=%0b r10=%0b r25=%0b  state=%b",
             $time, label, amount_display, dispense_item, return_5, return_10, return_25, dut.current_state);
    // drop the pulse
    @(negedge clk);
    coin_5  = 0;  coin_10 = 0;  coin_25 = 0;
    // give one clean idle edge so state can settle
    @(posedge clk);
  endtask

  initial begin
    // Reset
    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // ----- Sequence: 5 -> 10 -> 25 -----

    // 1) Add 5 : expect state= five (3'b001), display=5, no vend/returns
    pulse_coin(1,0,0, "coin_5");
    assert (dut.current_state == 3'b001)
      else $fatal("Expected FIVE (001), got %b", dut.current_state);

    // 2) Add 10: expect state= fifteen (3'b011), display=15, no vend/returns
    pulse_coin(0,1,0, "coin_10");
    assert (dut.current_state == 3'b011)
      else $fatal("Expected FIFTEEN (011), got %b", dut.current_state);

    // 3) Add 25: during this pulse expect vend + return_10 (Mealy),
    //            then next state should be Start (3'b000)
    @(negedge clk);
    coin_25 = 1;
    @(posedge clk); // sample during the coin_25 pulse
    $display("[%0t] %-22s | disp=%0d di=%0b r5=%0b r10=%0b r25=%0b  state=%b",
             $time, "coin_25", amount_display, dispense_item, return_5, return_10, return_25, dut.current_state);

    // Check vend + change (your RTL sets amount_display=40, di=1, r10=1)
    assert (amount_display == 40 && dispense_item && return_10 && !return_5 && !return_25)
      else $fatal("Expected dispense_item=1 and return_10=1 with disp=40 on the 25-coin pulse.");

    // drop coin_25 and let state update back to Start
    @(negedge clk); coin_25 = 0;
    @(posedge clk);
    assert (dut.current_state == 3'b000)
      else $fatal("Expected START (000) after vend, got %b", dut.current_state);

    $display("PASS: 5 -> 10 -> 25 => vend + return_10, then Start");
    $finish;
  end

  // sanity: never drive two coins at once
  always @(posedge clk) begin
    assert ((coin_5 + coin_10 + coin_25) <= 1)
      else $error("Multiple coins driven simultaneously");
  end

endmodule

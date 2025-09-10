`timescale 1ns / 1ps

module tb_lab4b;

    // Inputs
    logic clk;
    logic rst_n;
    logic coin_5;
    logic coin_10;
    logic coin_25;
    logic coin_return;

    // Outputs
    logic dispense_item;
    logic return_5;
    logic return_10;
    logic return_25;
    logic [5:0] amount_display;

    // Instantiate the Unit Under Test (UUT)
    lab4b uut (
        .clk             (clk),
        .rst_n           (rst_n),
        .coin_5          (coin_5),
        .coin_10         (coin_10),
        .coin_25         (coin_25),
        .coin_return     (coin_return),
        .dispense_item   (dispense_item),
        .return_5        (return_5),
        .return_10       (return_10),
        .return_25       (return_25),
        .amount_display  (amount_display)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period, 100 MHz
    end

    // Waveform dump for viewing simulation results
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, tb_lab4b);
    end

    // Test sequence
    initial begin
        $monitor("Time=%0t, state=%s, current_balance=%d, dispense=%b, return_25=%b, return_10=%b, return_5=%b", 
                 $time, uut.state.name(), amount_display, dispense_item, return_25, return_10, return_5);

        // 1. Initial State: Reset
        $display("\n--- Test Scenario 1: Reset ---");
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        #10;
        rst_n = 1;
        #10;

        // 2. Scenario 2: Exact amount (10 + 20) -> Dispense, no change
        $display("\n--- Test Scenario 2: Exact amount (10 + 20) ---");
        coin_10 = 1; // Insert 10 cents
        #10;
        coin_10 = 0;
        coin_25 = 1; // Insert 25 cents (makes it 35)
        #10;
        coin_25 = 0;
        #10; // State should go to DISPENSE
        #10; // State should go to RETURN_COINS with 5 cents
        #10; // State should go back to IDLE
        
        // 3. Scenario 3: Overpay (25 + 10) -> Dispense, then press coin return for change
        $display("\n--- Test Scenario 3: Overpay (25 + 10) ---");
        coin_25 = 1; // Insert 25 cents
        #10;
        coin_25 = 0;
        coin_10 = 1; // Insert 10 cents
        #10;
        coin_10 = 0;
        #10; // State is DISPENSE
        $display("Balance is %d, Waiting for coin_return for change...", amount_display);
        #10; // State is still DISPENSE, dispense_item should be 1
        coin_return = 1; // Press coin return
        #10;
        coin_return = 0;
        #10; // State should be RETURN_COINS, return_5 should be 1
        #10; // State should be IDLE, all outputs 0
        
        // 4. Scenario 4: Coin return before purchase
        $display("\n--- Test Scenario 4: Coin return before purchase ---");
        #10;
        coin_5 = 1; // Insert 5 cents
        #10;
        coin_5 = 0;
        #10;
        coin_return = 1; // Request coin return
        #10;
        coin_return = 0;
        #10; // State is RETURN_COINS, return_5 is 1
        #10; // State is IDLE, all outputs 0

        $display("\n--- Test complete ---");
        $finish;
    end
endmodule
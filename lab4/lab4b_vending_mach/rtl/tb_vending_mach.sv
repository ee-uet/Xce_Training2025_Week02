`timescale 1ns / 1ps

module tb_vending_mach;

    // inputs
    logic clk;
    logic rst_n;
    logic coin_5;
    logic coin_10;
    logic coin_25;
    logic coin_return;

    // outputs
    logic dispense_item;
    logic return_5;
    logic return_10;
    logic return_25;
    logic [5:0] amount_display;

    // instantiate the unit under test (uut)
    vending_mach uut (
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

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // waveform dump for viewing simulation results
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, tb_vending_mach); // corrected to match module name
    end

    // test sequence
    initial begin
        // monitor state, balance, and outputs for debugging
        $monitor("Time=%0t, state=%s, current_balance=%d, dispense=%b, return_25=%b, return_10=%b, return_5=%b", 
                 $time, uut.state.name(), amount_display, dispense_item, return_25, return_10, return_5);

        // test scenario 1: reset
        $display("\n--- Test Scenario 1: Reset ---");
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        #10; // apply reset
        rst_n = 1;
        #10; // release reset, expect idle state

        // test scenario 2: exact amount (10 + 20) for item
        $display("\n--- Test Scenario 2: Exact amount (10 + 20) ---");
        coin_10 = 1; // insert 10 cents
        #10;
        coin_10 = 0;
        coin_25 = 1; // insert 25 cents, total 35 cents
        #10;
        coin_25 = 0;
        #10; // expect dispense state
        #10; // expect return_coins state with 5 cents change
        #10; // expect return to idle state
        
        // test scenario 3: overpay (25 + 10) and request change
        $display("\n--- Test Scenario 3: Overpay (25 + 10) ---");
        coin_25 = 1; // insert 25 cents
        #10;
        coin_25 = 0;
        coin_10 = 1; // insert 10 cents, total 35 cents
        #10;
        coin_10 = 0;
        #10; // expect dispense state
        $display("Balance is %d, Waiting for coin_return for change...", amount_display);
        #10; // dispense_item should be 1
        coin_return = 1; // press coin return for change
        #10;
        coin_return = 0;
        #10; // expect return_coins state, return_5 should be 1
        #10; // expect idle state, all outputs 0
        
        // test scenario 4: coin return before purchase
        $display("\n--- Test Scenario 4: Coin return before purchase ---");
        #10;
        coin_5 = 1; // insert 5 cents
        #10;
        coin_5 = 0;
        #10;
        coin_return = 1; // request coin return
        #10;
        coin_return = 0;
        #10; // expect return_coins state, return_5 is 1
        #10; // expect idle state, all outputs 0

        $display("\n--- Test complete ---");
        $finish; // end simulation
    end
endmodule
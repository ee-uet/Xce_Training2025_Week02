`timescale 1ns/1ps

module tb_vending_machine;

    // Testbench signals
    logic clk;
    logic rst;
    
    logic coin_5, coin_10, coin_25;
    logic coin_5_pulse, coin_10_pulse, coin_25_pulse;
    
    logic return_req;
    logic return_5, return_10, return_25;
    logic dispense_item;
    logic [7:0] amount;

    // Instantiate coin synchronizer
    synchronization_for_coins sync_coins (
        .clk(clk),
        .rst(rst),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_25(coin_25),
        .coin_5_pulse(coin_5_pulse),
        .coin_10_pulse(coin_10_pulse),
        .coin_25_pulse(coin_25_pulse)
    );

    // Instantiate vending machine
    vending_machine vm (
        .clk(clk),
        .rst(rst),
        .coin_5_pulse(coin_5_pulse),
        .coin_10_pulse(coin_10_pulse),
        .coin_25_pulse(coin_25_pulse),
        .return_req(return_req),
        .return_5(return_5),
        .return_10(return_10),
        .return_25(return_25),
        .dispense_item(dispense_item),
        .amount(amount)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        coin_5 = 0; coin_10 = 0; coin_25 = 0;
        return_req = 0;
        
        #20; // Wait 2 clock cycles
        rst = 0;

        // Insert coins to reach 30 (5 + 10 + 25 > 30)
        #10; coin_5 = 1;
        #10; coin_5 = 0;
        
        #10; coin_10 = 1;
        #10; coin_10 = 0;
        
        #10; coin_25 = 1;
        #10; coin_25 = 0;
        
        // Check dispense
        #20;
        
        // Request return
        return_req = 1;
        #50;  // Allow multiple clocks to return change
        return_req = 0;

        // Insert exact change
        #10; coin_25 = 1;
        #10; coin_25 = 0;
        #10; coin_5 = 1;
        #10; coin_5 = 0;

        // Wait for dispense
        #20;

        // Finish simulation
        #50;
        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\tClk\tAmount\tDispense\tReturn_5\tReturn_10\tReturn_25");
        $monitor("%0t\t%b\t%0d\t%b\t\t%b\t\t%b\t\t%b", 
                 $time, clk, amount, dispense_item, return_5, return_10, return_25);
    end

endmodule

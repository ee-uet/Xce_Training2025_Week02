module tb_vending_machine();
    logic       clk;
    logic       rst_n;
    logic       coin_5;
    logic       coin_10;
    logic       coin_25;
    logic       coin_return;
    logic       dispense_item;
    logic       return_5;
    logic       return_10;
    logic       return_25;
    logic [5:0] amount_display;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate the vending machine
    vending_machine dut (
        .clk(clk),
        .rst_n(rst_n),
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
    
    initial begin
        // Initialize VCD dump
        $dumpfile("4B.vcd");
        $dumpvars(0, tb_vending_machine);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        
        // Test 1: Reset (synchronous)
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("Time=%t: Reset released - Amount=%d cents", $time, amount_display);
        
        // Test 2: Insert coins to reach 30 cents (dispense)
        // Insert 25 cent coin (hold for one full cycle)
        @(posedge clk);
        coin_25 = 1;
        @(posedge clk);
        coin_25 = 0;
        @(posedge clk);
        $display("Time=%t: Inserted 25 cents - Amount=%d cents", $time, amount_display);
        
        // Insert 5 cent coin (hold for one full cycle)
        @(posedge clk);
        coin_5 = 1;
        @(posedge clk);
        coin_5 = 0;
        @(posedge clk);
        $display("Time=%t: Inserted 5 cents - Amount=%d cents", $time, amount_display);
        
        // Wait for dispense
        repeat(2) @(posedge clk);
        $display("Time=%t: After transaction - Dispensed=%b", $time, dispense_item);
        
        // Test 3: Insert coins and request return
        repeat(2) @(posedge clk);
        
        // Insert 10 cent coin
        @(posedge clk);
        coin_10 = 1;
        @(posedge clk);
        coin_10 = 0;
        @(posedge clk);
        $display("Time=%t: Inserted 10 cents - Amount=%d cents", $time, amount_display);
        
        // Request coin return
        @(posedge clk);
        coin_return = 1;
        @(posedge clk);
        coin_return = 0;
        @(posedge clk);
        $display("Time=%t: Coin return requested", $time);
        
        // Wait for return process
        repeat(5) @(posedge clk);
        $display("Time=%t: After return - Return_5=%b, Return_10=%b, Return_25=%b", 
                 $time, return_5, return_10, return_25);
        
        // Test 4: Insert coins for complex return scenario (35 cents)
        repeat(2) @(posedge clk);
        
        // Insert 25 cent coin
        @(posedge clk);
        coin_25 = 1;
        @(posedge clk);
        coin_25 = 0;
        @(posedge clk);
        $display("Time=%t: Inserted 25 cents - Amount=%d cents", $time, amount_display);
        
        // Insert 10 cent coin
        @(posedge clk);
        coin_10 = 1;
        @(posedge clk);
        coin_10 = 0;
        @(posedge clk);
        $display("Time=%t: Inserted 10 cents - Amount=%d cents", $time, amount_display);
        
        // Wait for dispense and return (should get 5 cents back)
        repeat(5) @(posedge clk);
        $display("Time=%t: After transaction - Dispensed=%b, Return_5=%b, Return_10=%b, Return_25=%b", 
                 $time, dispense_item, return_5, return_10, return_25);
        
        // Finish simulation
        repeat(10) @(posedge clk);
        $display("Time=%t: Test completed", $time);
        $finish;
    end
    
endmodule

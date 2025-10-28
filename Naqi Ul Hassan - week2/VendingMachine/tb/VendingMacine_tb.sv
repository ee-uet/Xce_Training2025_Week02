module VendingMachine_tb;

    logic       clk, rst_n;
    logic       coin_5, coin_10, coin_25, coin_return;
    logic       dispense_item, ret_5, ret_10, ret_25;
    logic [5:0] amount_display;

    VendingMachine dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .coin_5         (coin_5),
        .coin_10        (coin_10),
        .coin_25        (coin_25),
        .coin_return    (coin_return),
        .dispense_item  (dispense_item),
        .ret_5          (ret_5),
        .ret_10         (ret_10),
        .ret_25         (ret_25),
        .amount_display (amount_display)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor
    initial begin
        $display("Time | 5c |10c |25c |Ret |Dispense |Ret5 |Ret10 |Ret25 |Amount");
        $monitor("%4t |  %b | %b  | %b  | %b |    %b    |  %b  |  %b   |  %b   | %0d",
                  $time, coin_5, coin_10, coin_25, coin_return,
                  dispense_item, ret_5, ret_10, ret_25, amount_display);
    end

    // Stimulus
    initial begin
        rst_n = 0; coin_5 = 0; coin_10 = 0; coin_25 = 0; coin_return = 0;
        @(posedge clk);
        rst_n = 1;

        // Insert coins: 5c + 10c + 25c → should dispense
        @(posedge clk); coin_5 = 1; @(posedge clk); coin_5 = 0;
        @(posedge clk); coin_10 = 1; @(posedge clk); coin_10 = 0;
        @(posedge clk); coin_25 = 1; @(posedge clk); coin_25 = 0;

        // Insert 5c then return
        @(posedge clk); coin_5 = 1; @(posedge clk); coin_5 = 0;
        @(posedge clk); coin_return = 1; @(posedge clk); coin_return = 0;

        // Wait a few cycles to observe
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule

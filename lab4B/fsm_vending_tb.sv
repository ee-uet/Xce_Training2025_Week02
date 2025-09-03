module fsm_vending_tb;

    logic clk, rst_n;
    logic coin_5, coin_10, coin_25, coin_return;
    logic dispense_item, ret_5, ret_10, ret_25;
    logic [4:0] amount_display;

    fsm_vending dut (
        .clk(clk),
        .rst_n(rst_n),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_25(coin_25),
        .coin_return(coin_return),
        .dispense_item(dispense_item),
        .ret_5(ret_5),
        .ret_10(ret_10),
        .ret_25(ret_25),
        .amount_display(amount_display)
    );


    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
       
        rst_n = 1;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        @(posedge clk);
        @(posedge clk);
        // Insert 5c coin
        coin_5 = 1;
        @(posedge clk);
        coin_5 = 0;

        // Insert 10c coin
        coin_10 = 1;
        @(posedge clk);
        coin_10 = 0;

        // Insert 25c coin
        coin_25 = 1;
        @(posedge clk);
        coin_25 = 0;
        @(posedge clk);
        // checking return coin functionality
        coin_5 = 1;
        @(posedge clk);
        coin_5 = 0;
        @(posedge clk);
        coin_return = 1;
        @(posedge clk);
        coin_return = 0;

       
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
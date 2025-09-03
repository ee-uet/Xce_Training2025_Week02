module tb_vending_machine;

    logic clk;
    logic rst_n;
    logic coin_5, coin_10, coin_25, coin_return;
    logic dispense;
    logic [5:0] amount_display;
    logic return_5;
    logic [1:0] return_10;
    logic return_25;

    vending_machine dut (
        .clk(clk),
        .rst_n(rst_n),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_25(coin_25),
        .coin_return(coin_return),
        .dispense(dispense),
        .amount_display(amount_display),
        .return_5(return_5),
        .return_10(return_10),
        .return_25(return_25)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        #20;
        rst_n = 1;

        #10 coin_10 = 1; #10 coin_10 = 0;   // Insert 10c
        #20 coin_10 = 1; #10 coin_10 = 0;   // Insert 10c
        #20 coin_10 = 1; #10 coin_10 = 0;   // Insert 10c (total 30c, should dispense)

        #50 coin_25 = 1; #10 coin_25 = 0;   // Insert 25c
        #20 coin_10 = 1; #10 coin_10 = 0;   // Insert 10c (total 35c, should dispense + return 5c)

        #50 coin_25 = 1; #10 coin_25 = 0;   // Insert 25c
        #20 coin_return = 1; #10 coin_return = 0; // Cancel, should return 25c

        #100 $finish;
    end

endmodule

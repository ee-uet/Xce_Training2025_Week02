module vending_machine_tb;
    logic clk;
    logic rst_n;
    logic coin_5;
    logic coin_10;
    logic coin_25;
    logic coin_return;
    logic dispense_item;
    logic return_5;
    logic return_10;
    logic return_25;
    logic [5:0] amount_display;

    // Instantiate the vending machine
    vending_machine uut (
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

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Reset
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;
        @(posedge clk);
        rst_n = 1;

        // Insert coins to make 20 cents (e.g., 10 + 10)
        coin_5 = 1; @(posedge clk); coin_5 = 0;
        coin_25 = 1; @(posedge clk); coin_25 = 0;
        coin_return = 1; @(posedge clk); coin_return = 0;
        $display("After inserting 30 cents: dispense_item=%0d, return_5=%0d, return_10=%0d, return_25=%0d, amount=%0d",
                 dispense_item, return_5, return_10, return_25, amount_display);

        $stop;
    end
endmodule

module tb_vending_machine_fsm;

    logic clk;
    logic rst_n;
    logic coin_5;
    logic coin_10;
    logic coin_25;
    logic coin_return;
    logic dispense_item;
    logic return_10;
    logic return_5;
    logic return_25;
    logic [5:0] amount_display;

    // DUT instantiation
    vending_machine_fsm dut (
        .clk(clk),
        .rst_n(rst_n),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_25(coin_25),
        .coin_return(coin_return),
        .dispense_item(dispense_item),
        .return_10(return_10),
        .return_5(return_5),
        .return_25(return_25),
        .amount_display(amount_display)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;

        #20;
        rst_n = 1;

        // Test 1: insert coins to reach 30
        #10; coin_25 = 1;
        #10; coin_25 = 0;
        #10; coin_5  = 1;
        #10; coin_5  = 0;

        #20;

        // Test 2: insert coins to exceed 30
        #10; coin_25 = 1;
        #10; coin_25 = 0;
        #10; coin_10 = 1;
        #10; coin_10 = 0;


        #20;

        // Test 3: coin return at amount < 30
        #10; coin_5 = 1;
        #10; coin_5 = 0;
        #10; coin_10 = 1;
        #10; coin_10 = 0;
        #10; coin_return = 1;
        #10; coin_return = 0;

        // Test 4: coin jam
        #10; coin_25 = 1;
        #10; coin_25 = 0;
        #10; coin_5 = 1;
        #10; coin_5 = 0;

        #50;

        $finish;
    end

    // Monitoring outputs
    initial begin
        $display("Time\tclk\trst\tamount\tD\tr5\tr10\tr25");
        $monitor("%0t\t%b\t%b\t%0d\t%b\t%b\t%b\t%b",
                 $time, clk, rst_n, amount_display, dispense_item, return_5, return_10, return_25);
    end

endmodule

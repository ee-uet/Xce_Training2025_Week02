module fsm_vendingmachine_tb;

    // DUT signals
    logic clk;
    logic rst_n;
    logic coin_5, coin_10, coin_25, coin_return;
    logic dispense_item;
    logic return_5, return_10, return_25;
    logic [5:0] amount_display;

    // Instantiate DUT
    fsm_vendingmachine dut (
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

    // Clock generation (10 time units per cycle)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        coin_5 = 0;
        coin_10 = 0;
        coin_25 = 0;
        coin_return = 0;

        // Apply reset
        @(posedge clk);
        rst_n <= 1;

        // Insert a 5-cent coin
        @(posedge clk);
        coin_5 <= 1;
        @(posedge clk);
        coin_5 <= 0;

        // Insert a 10-cent coin
        @(posedge clk);
        coin_10 <= 1;
        @(posedge clk);
        coin_10 <= 0;

        // Insert a 25-cent coin → should trigger dispense
        @(posedge clk);
        coin_25 <= 1;
        @(posedge clk);
        coin_25 <= 0;

        // Try coin return after inserting 10 cents
        @(posedge clk);
        coin_10 <= 1;
        @(posedge clk);
        coin_10 <= 0;

        @(posedge clk);
        coin_return <= 1;
        @(posedge clk);
        coin_return <= 0;

        // Insert multiple coins
        @(posedge clk);
        coin_25 <= 1;
        @(posedge clk);
        coin_25 <= 0;

        @(posedge clk);
        coin_10 <= 1;
        @(posedge clk);
        coin_10 <= 0;

        // End simulation
        repeat(10) @(posedge clk);
        $stop;
    end

    // Monitor outputs
    initial begin
        $display("Time\tState\tAmt\tDisp\tR5 R10 R25");
        forever @(posedge clk) begin
            $display("%0t\t%b\t%d\t%b\t%b  %b  %b",
                     $time, dut.current_state, amount_display,
                     dispense_item, return_5, return_10, return_25);
        end
    end

endmodule

import pkg::*;

module vending_machine_tb #(parameter TESTS = 1000)();
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
    display [5:0] amount_display;

    vending_machine Vending_Machine(.*);

    initial begin
        clk = 1'b0;
        forever begin
            #5 clk = ~clk; 
        end
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        {coin_5, coin_10, coin_25, coin_return} = 0;

        
        #20;
        rst_n = 1;

        // Random test sequence
        for (int i = 0; i < TESTS; i++) begin
            @(posedge clk);
            // Randomly insert coins or request return
            coin_5  = $urandom_range(0, 1);
            coin_10 = $urandom_range(0, 1);
            coin_25 = $urandom_range(0, 1);
            coin_return = $urandom_range(0, 1);

            $display("coin_5=%d, coin_10=%d, coin_25=%d, coin_return=%d",
                     coin_5, coin_10, coin_25, coin_return);

            @(posedge clk);
            {coin_5, coin_10, coin_25, coin_return} = 0; // Clear inputs

            $display("dispense_item=%d, return_5=%d, return_10=%d, return_25=%d, amount_display=%b",
                    dispense_item, return_5, return_10, return_25, amount_display);
        end

        $stop;
    end
endmodule
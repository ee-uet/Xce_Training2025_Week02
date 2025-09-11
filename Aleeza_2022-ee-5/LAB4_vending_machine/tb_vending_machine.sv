module tb_vending_machine;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic coin_5, coin_10, coin_25, coin_return;
    logic dispense_item, return_5, return_10, return_25;
    logic [5:0] amount_display;

    // DUT instantiation
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

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // --- TASKS ---
    task insert_coin(input string coin_type);
        begin
            case (coin_type)
                "5":  coin_5  = 1;
                "10": coin_10 = 1;
                "25": coin_25 = 1;
            endcase

            @(posedge clk);   // keep coin high for one full cycle
            coin_5 = 0; coin_10 = 0; coin_25 = 0;
        end
    endtask

    task press_return();
        begin
            coin_return = 1;
            @(posedge clk);   // keep return high for one cycle
            coin_return = 0;
        end
    endtask

    // --- TEST SEQUENCE ---
    initial begin
        // Initialize
        rst_n = 0;
        coin_5 = 0; coin_10 = 0; coin_25 = 0; coin_return = 0;
        @(posedge clk);
        rst_n = 1;

        // Insert coins
        $display("=== Test: Insert 5, then 10 ===");
        insert_coin("5");
        insert_coin("10");

        $display("=== Test: Insert 25 directly ===");
        insert_coin("25");

        $display("=== Test: Insert 10, press return ===");
        insert_coin("10");
        press_return();

        $display("=== Test Complete ===");
        #50;
        $stop;
    end

endmodule


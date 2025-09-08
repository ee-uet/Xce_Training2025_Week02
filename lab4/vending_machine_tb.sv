module vending_machine_tb ();
logic clk,
logic rst_n,
logic coin_5,
logic coin_10, // 10-cent coin inserted
logic coin_25, // 25-cent coin inserted
logic coin_return,
logic dispense_item,
logic return_5, // Return 5-cent
logic return_10, // Return 10-cent
logic return_25, // Return 25-cent
logic [5:0] amount_display

initial begin
    clk = 1'b0;
    forever begin
        #5 clk = ~clk; 
    end
end

endmodule
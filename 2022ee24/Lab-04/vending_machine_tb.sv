module vending_machine_tb;

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

vending_machine uut(
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
    clk = 1;
end
always #5 clk = ~clk;

initial begin
    rst_n = 1'b0;
    coin_5 = 1'b0;
    coin_10 = 1'b0;
    coin_25 = 1'b0;
    coin_return  =1'b0;
    #10;
    rst_n = 1'b1;
    coin_5 = 1'b1;
    #10;
    coin_5 = 1'b0;
    coin_10 = 1'b1;
    #10
    coin_10 = 1'b0;
    #10;
    coin_25 = 1'b1;
    #10
    coin_25 = 1'b0;
    #10;
    $stop;
end

endmodule
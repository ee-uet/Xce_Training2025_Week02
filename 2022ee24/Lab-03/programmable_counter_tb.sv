module programmable_counter_tb;

logic        clk;
logic        rst_n;        
logic        load;         
logic        enable;       
logic        up_down;       
logic [7:0]  load_value;   
logic [7:0]  max_count;   
logic [7:0]  count;        
logic        tc;
logic        zero;

programmable_counter utt(
    .clk(clk),
    .rst_n(rst_n),        
    .load(load),         
    .enable(enable),       
    .up_down(up_down),     
    .load_value(load_value),  
    .max_count(max_count),    
    .count(count),       
    .tc(tc),          
    .zero(zero)  
);


initial begin
    clk = 1;
    rst_n = 1'b0;
end

always #5 clk = ~clk;

initial begin
    load = 1'b0;
    enable = 1'b0;
    max_count = 8'b0;
    load_value = 8'd10;
    up_down = 1'b0;
    #10;
    rst_n = 1'b1;
    load = 1'b1;
    #10;
    load = 1'b0;
    enable = 1'b1;
    max_count = 8'd15;
    #50;
    up_down = 1'b1;
    #160;
    #10;
end

endmodule
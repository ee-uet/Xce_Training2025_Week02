module prog_counter_tb;
logic clk;
logic rst_n;
logic load;
logic enable;
logic up_down;
logic [7:0] load_value;
logic [7:0] max_count;
logic [7:0] count;
logic tc;
logic zero;
prog_counter uut (
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
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    rst_n =         0;
    load =          0;
    enable =        0;
    up_down =       0;
    load_value =    8'd0;
    max_count =     8'd10;
    #3;
    rst_n = 1; load = 1; load_value = 8'd5;
    @(posedge clk);
    #5;
    // Testing count up
    enable = 1; load = 0; up_down = 1;
    repeat (2) @(posedge clk);
    // Testing disable functionality
    enable = 0;
    @(posedge clk);
    enable = 1;
    @(posedge clk);
    // Testing down counting
    up_down = 0;
    repeat (15) @(posedge clk);
    enable = 0;
    @(posedge clk);
    $finish;
end
endmodule
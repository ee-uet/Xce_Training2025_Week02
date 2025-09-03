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
programmable_counter uut (
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
    rst_n = 0;
    load = 0;
    enable = 0;
    up_down = 0;
    load_value = 8'd0;
    max_count = 8'd10;
    #12;
    rst_n = 1;
    #10;
    load = 1;
    load_value = 8'd5;
    #10;
    load = 0;
    enable = 1;
    up_down = 1;
    @(posedge clk);
    repeat (15) @(posedge clk);
    up_down = 0;
    @(posedge clk);
    repeat (15) @(posedge clk);
    enable = 0;
    #10;
    $finish;
end
endmodule
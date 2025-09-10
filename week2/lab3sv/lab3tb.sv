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

    programmable_counter dut (
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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        load = 0;
        enable = 0;
        up_down = 0;
        load_value = 8'd5; 
        max_count = 8'd10;

        #10 rst_n = 1;
        #10 load = 1;
        #10 load = 0;
        enable = 1;
        #60;
        $finish;
    end

    initial begin
        $monitor("Time=%0t | count=%0d | tc=%b | zero=%b", $time, count, tc, zero);
    end
endmodule

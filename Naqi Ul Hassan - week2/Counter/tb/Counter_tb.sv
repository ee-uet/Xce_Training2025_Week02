module Counter_tb;
    logic       clk, rst_n, load, enable, up_down;
    logic [7:0] load_value, max_count, count;
    logic       tc, zero;

    Counter uut (
        .clk        (clk), 
        .rst_n      (rst_n),
        .load       (load), 
        .enable     (enable),
        .up_down    (up_down), 
        .load_value (load_value), 
        .max_count  (max_count),
        .count      (count), 
        .tc         (tc), 
        .zero       (zero)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0; load = 0; enable = 0; up_down = 0; load_value = 0; max_count = 10;
        #3 
        rst_n = 1; load = 1; load_value = 5;
        @(posedge clk);
        load = 0; enable = 1; up_down = 1;
        repeat (5) @(posedge clk);
        enable = 0; @(posedge clk);
        enable = 1; @(posedge clk);
        up_down = 0; repeat (15) @(posedge clk);
        enable = 0; @(posedge clk);
        $finish;
    end
endmodule

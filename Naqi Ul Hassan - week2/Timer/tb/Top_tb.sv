module Top_tb;
    logic           clk;
    logic           reset_n;
    logic           start;
    logic [1:0]     mode;
    logic [15:0]    prescale_val;
    logic [31:0]    reload_value;
    logic [31:0]    compare_value;
    logic           time_out;
    logic           pwm_out;

    Top dut (
        .clk            (clk),
        .reset_n        (reset_n),
        .start          (start),
        .mode           (mode),
        .prescale_val   (prescale_val),
        .reload_value   (reload_value),
        .compare_value  (compare_value),
        .time_out       (time_out),
        .pwm_out        (pwm_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n      = 0;
        start        = 0;
        mode         = 2'b00;
        prescale_val = 16'd2;
        reload_value = 32'd10;
        compare_value= 32'd5;

        #20 reset_n = 1;

        // One-shot test
        start = 1; mode = 2'b01;
        #10 start = 0;
        #200;

        // Periodic test
        start = 1; mode = 2'b10;
        #10 start = 0;
        #400;

        // PWM test
        start = 1; mode = 2'b11;
        #10 start = 0;
        #600;

        // Off mode
        start = 1; mode = 2'b00;
        #10 start = 0;
        #100;

        $finish;
    end
endmodule

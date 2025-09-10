module tb_multi_mode_timer;

    logic clk;
    logic rst_n;
    logic [1:0] mode;
    logic [15:0] prescaler;
    logic [31:0] reload_val;
    logic [31:0] compare_val;
    logic start;
    logic timeout;
    logic pwm_out;
    logic [31:0] current_count;

    multi_mode_timer dut (.*);

    initial clk = 0;
    always #5 clk = ~clk; 

    // Test sequence
    initial begin
        // Initial reset
        rst_n = 0;
        mode = 2'b00;
        prescaler = 4;     // prescaler divide
        reload_val = 10;   
        compare_val = 5;   // 50% duty cycle
        start = 0;
        #50;               

        rst_n = 1;
        #20;

        // One-shot mode test

        mode = 2'b01;
        start = 1; #10; start = 0;
        wait (timeout);
        $display("One-shot timeout at count=%0d", current_count);
        #50;

        // Periodic mode test

        mode = 2'b10;
        start = 1; #10; start = 0;
        repeat (3) begin
            wait (timeout);
            $display("Periodic timeout, count=%0d", current_count);
            #20;
        end

        // PWM mode test
 
        mode = 2'b11;
        start = 1; #10; start = 0;
        repeat (40) begin
            @(posedge clk);
            $display("Count=%0d | PWM=%b", current_count, pwm_out);
        end

        $stop;
    end

endmodule

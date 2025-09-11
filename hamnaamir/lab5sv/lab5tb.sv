`timescale 1ns/1ps

module tb_pwm_timer;

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

    // DUT
    multi_mode_timer dut (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .prescaler(prescaler),
        .reload_val(reload_val),
        .compare_val(compare_val),
        .start(start),
        .timeout(timeout),
        .pwm_out(pwm_out),
        .current_count(current_count)
    );

    // Clock (#0.5 with 1ns timescale => 1 GHz, 1 ns period)
    initial clk = 0;
    always #0.5 clk = ~clk;

    // Make a safe start pulse (long enough for pre_clk domain)
    task automatic pulse_start;
        begin
            start = 1;
            #20;        // ~20 clk cycles high
            start = 0;
        end
    endtask

    initial begin
        // ----- Common init -----
        rst_n       = 0;
        mode        = 2'b00;
        prescaler   = 16'd4;     // decrement every 2*prescaler*1ns = 8 ns
        reload_val  = 32'd20;    // SAME for all modes
        compare_val = 32'd8;     // duty for PWM
        start       = 0;

        // Reset
        #5 rst_n = 1;

        // ===================== ONE-SHOT (finish once) =====================
        mode = 2'b01;
        pulse_start();
        // With prescaler=4, each tick = ~8ns; 20 ticks ≈ 160ns
        // Wait for exactly one completion
        @(posedge timeout);
        #20;

        // ============== PERIODIC (do NOT let it finish) ===================
        mode = 2'b10;            // mode change triggers reload inside DUT
        pulse_start();
        // Do NOT wait for timeout; leave before 20 ticks (~160ns)
        #80;                     // <160ns, so periodic won't complete

        // ===================== PWM (complete once) ========================
        mode = 2'b11;            // mode change reloads
        pulse_start();           // explicit start (extra safe)
        // One PWM "period" = reload_val counts; DUT asserts timeout on wrap
        @(posedge timeout);      // wait for exactly one wrap in PWM
        #40;

        $display("TEST DONE @ %0t", $time);
        $stop;
    end

    // Simple monitor
    initial begin
        $display("Time(ns)\tMode\tCount\tPWM\tTO");
        $monitor("%0t\t%02b\t%0d\t%b\t%b",
                 $time, mode, current_count, pwm_out, timeout);
    end

endmodule

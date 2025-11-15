`timescale 1ns/1ps

module tb_multi_mode_timer;

    // DUT signals
    logic clk, rst;
    logic [1:0] mode_sel;
    logic start;
    logic [31:0] duty_cycle;
    logic [31:0] Load_Value;
    logic pwm_out;
    logic one_shot_mode_interupt, periodic_mode_interupt, pwm_mode_interupt;
    logic [31:0] count_out;

    // Clock generator (simulated divided clock)
    initial clk = 0;
    always #10 clk = ~clk;   // 50 MHz clock -> period 20ns

    // Instantiate DUT
    multi_mode_timer uut (
        .divided_clk(clk),
        .rst(rst),
        .mode_sel(mode_sel),
        .start(start),
        .duty_cycle(duty_cycle),
        .Load_Value(Load_Value),
        .pwm_out(pwm_out),
        .one_shot_mode_interupt(one_shot_mode_interupt),
        .periodic_mode_interupt(periodic_mode_interupt),
        .pwm_mode_interupt(pwm_mode_interupt),
        .count_out(count_out)
    );

    // Stimulus
    initial begin
        // VCD for waveform
        $dumpfile("tb_multi_mode_timer.vcd");
        $dumpvars(0, tb_multi_mode_timer);

        // Initialize
        rst = 1;
        start = 0;
        mode_sel = 2'b00;
        duty_cycle = 0;
        Load_Value = 0;
        #50;
        rst = 0;

        // --- Mode 00: Hold ---
        $display("=== Testing HOLD Mode ===");
        mode_sel = 2'b00;
        Load_Value = 12;
        start = 1;
        #200;

        // --- Mode 01: One-Shot ---
        $display("=== Testing ONE-SHOT Mode ===");
        mode_sel = 2'b01;
        Load_Value = 8;
        #300;

        // --- Mode 10: Periodic ---
        $display("=== Testing PERIODIC Mode ===");
        mode_sel = 2'b10;
        Load_Value = 6;
        #400;

        // --- Mode 11: PWM ---
        $display("=== Testing PWM Mode ===");
        mode_sel = 2'b11;
        Load_Value = 10;
        duty_cycle = 5;
        #500;

        $display("=== Simulation Finished ===");
        $finish;
    end

    // Console monitor
    initial begin
        $monitor("T=%0t | Mode=%b | Count=%0d | PWM=%b | OneShotInt=%b | PeriodicInt=%b | PWMInt=%b",
                 $time, mode_sel, count_out, pwm_out,
                 one_shot_mode_interupt, periodic_mode_interupt, pwm_mode_interupt);
    end

endmodule

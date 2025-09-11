`timescale 1ns/1ps
module tb_multimode;

    // testbench signals
    logic        clk;
    logic        rst_n;
    logic [1:0]  mode;
    logic [15:0] prescaler;
    logic [31:0] reload_val;
    logic [31:0] compare_val;
    logic        start;
    logic        timeout;
    logic        pwm_out;
    logic [31:0] current_count;

    // instantiate dut
    multimode dut (
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

    // clock generation: 1 mhz (1us period)
    initial clk = 0;
    always #500 clk = ~clk; // toggle every 500ns for 1us period

    // test sequence
    initial begin
        // initial reset and setup
        rst_n = 0;
        start = 0;
        mode = 2'b00;
        prescaler = 3;
        reload_val = 32'd4; // period = 10 ticks (reload value is 9)
        compare_val = 32'd1; // pwm duty cycle 3/10 = 30%
        #2000; // wait 2us for reset stabilization
        
        rst_n = 1; // release reset
        #2000; // wait for system to stabilize

        // start timer
        start = 1;
        #2000; // allow initial counter load
        
        // test pwm mode
        mode = 2'b11; // switch to pwm mode
        #20000; // run 20us to observe pwm output
        
        // test one-shot mode
        mode = 2'b01; // switch to one-shot mode
        #20000; // run 20us to observe single countdown
        
        // test periodic mode
        mode = 2'b10; // switch to periodic mode
        #20000; // run 20us to observe periodic reload
        
        // stop timer
        start = 0;
        $display("\nSimulation Finished");
        $finish; // end simulation
    end

endmodule
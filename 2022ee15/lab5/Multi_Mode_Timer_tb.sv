`timescale 1ns/1ps
//Multi-Mode Timer test bench
module Multi_Mode_Timer_tb;

    // Testbench signals
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

    // Instantiate DUT
    Multi_Mode_Timer dut (
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

    // Clock generation (1 MHz → 1us period → 1000 ns in sim for visibility)
    initial clk = 0;
    always #500 clk = ~clk;  // 1 MHz clock → 1us period

    // Test sequence
    initial begin
        // Initial reset
        rst_n = 0;
        start = 0;
        mode = 2'b00;
        prescaler = 3;
        reload_val = 32'd4; // period = 10 ticks (reload value is 9)
        compare_val = 32'd1; // duty = 3/10 = 30%
        #2000;   // wait 2us
        rst_n = 1;
		
		// Load Value
		start = 1;
		#2000;
		
        mode       = 2'b11;   
		
		
        #20000;               // run 20us
		mode       = 2'b01;   
		
		
        #20000;               // run 20us
		
		mode       = 2'b10;   
		
		
        #20000;               // run 20us
		
        
		start = 0;
        $display("\nSimulation Finished");
        $finish;
    end

endmodule

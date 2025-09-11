module multi_mode_timer_tb();

    // Signals
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
    
    // DUT instance
    multi_mode_timer uut(
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

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initial reset
        rst_n = 0;
        start = 0;
        mode = 2'b00;
        prescaler = 2;    // small prescaler for fast PWM
        reload_val = 3;   
        compare_val = 2;  

        @(posedge clk);
        rst_n = 1;

        // ----- OFF mode -----
        mode = 2'b00; start = 0;
        @(posedge clk); #20;

        // ----- ONE-SHOT mode -----
        mode = 2'b01; start = 1;
        @(posedge clk); start = 0;
        repeat(6) @(posedge clk);  // let one-shot finish

        // ----- PERIODIC mode -----
        mode = 2'b10; start = 1;
        repeat(10) @(posedge clk); // observe a few cycles
        start = 0;

        // ----- PWM mode -----
        mode = 2'b11; start = 1;
        repeat(20) @(posedge clk); // observe a few PWM pulses
        start = 0;

        $finish;
    end

endmodule

module tb_top_timer;

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

    // Instantiate the top module
    multi_mode_timer_top UUT (
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

    // Clock generation: 1 MHz
    initial clk = 0;
    always #0.5 clk = ~clk;  // period = 1us

    initial begin
        // Initialize
        rst_n = 0;
        mode = 2'b00;
        prescaler = 16'd4;   // divide clock by 5 for testing
        reload_val = 32'd20; // small number for fast simulation
        compare_val = 32'd5; // PWM duty cycle
        start = 0;

        #2;
        rst_n = 1;  // Release reset

        // Test One-shot
        mode = 2'b01;
        start = 1;
        #1 start = 0;
        #50;

        // Test Periodic
        mode = 2'b10;
        start = 1;
        #1 start = 0;
        #100;

        // Test PWM
        mode = 2'b11;
        start = 1;
        #1 start = 0;
        #100;

        $finish;
    end

endmodule

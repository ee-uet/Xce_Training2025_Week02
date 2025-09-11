module multi_mode_timer_tb;

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
    logic        tick_out;   // from DUT (prescaler tick)

    // Instantiate DUT
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
        .current_count(current_count),
        .tick_out(tick_out)   // new debug output
    );

    // Clock generation: 10ns → 100MHz
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize
        rst_n       = 0;
        start       = 0;
        mode        = 2'b00;
        prescaler   = 16'd9;      // Divide input clk by (prescaler+1)=10
        reload_val  = 32'd20;
        compare_val = 32'd5;
        #50;
        rst_n = 1;

        // ------------------------------------------------ 
        // Test One-Shot mode
        // ------------------------------------------------
        $display("\n=== One-Shot Test ===");
        mode       = 2'b01;   // one-shot
        reload_val = 32'd10;  // count 10 prescaler ticks
        start      = 1;  #10; start = 0;
        wait(timeout);
        $display("[%0t] One-shot timeout observed. Final count=%0d",$time,current_count);
        #100;

        // ------------------------------------------------
        // Test Periodic mode
        // ------------------------------------------------
        $display("\n=== Periodic Mode Test ===");
        mode       = 2'b10;   // periodic
        reload_val = 32'd15;  // reload every 15 prescaler ticks
        start      = 1;  #10; start = 0;
        repeat(3) begin
            wait(timeout);
            $display("[%0t] Periodic timeout pulse. Count reloaded to %0d",$time,current_count);
        end
        #100;

        // ------------------------------------------------
        // Test PWM mode
        // ------------------------------------------------
        $display("\n=== PWM Mode Test ===");
        mode        = 2'b11;   // PWM
        reload_val  = 32'd20;  // Period = 20 ticks
        compare_val = 32'd5;   // Duty = 5/20 = 25%
        start       = 1;  #10; start = 0;
        #200;  
        $display("[%0t] PWM running with 25%% duty",$time);

        compare_val = 32'd10;  // Duty = 50%
        #200;
        $display("[%0t] PWM duty changed to 50%%",$time);

        compare_val = 32'd15;  // Duty = 75%
        #200;
        $display("[%0t] PWM duty changed to 75%%",$time);

        // ------------------------------------------------
        // Test OFF mode
        // ------------------------------------------------
        $display("\n=== OFF Mode Test ===");
        mode  = 2'b00;
        #200;

        $finish;
    end

    // Debug prescaler tick frequency
    always @(posedge tick_out) begin
        $display("[%0t] Prescaler tick generated",$time);
    end

endmodule


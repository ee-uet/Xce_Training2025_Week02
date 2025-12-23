module multi_mode_timer_tb;

    // Testbench signals
    logic        clk;          // 1 MHz clock
    logic        rst_n;        // Active-low reset
    logic [1:0]  mode;         // Timer mode
    logic [15:0] prescaler;    // Clock divider
    logic [31:0] reload_val;   // Reload value
    logic [31:0] compare_val;  // PWM compare value
    logic        start;        // Start signal
    logic        timeout;      // Timeout output
    logic        pwm_out;      // PWM output
    logic [31:0] current_count; // Current count value
    
    // Instantiate the DUT (Device Under Test)
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
    
    // Clock generation: 1 MHz (1000 ns period)
    always #500 clk = ~clk; // 500ns half-period = 1MHz
    
    // Main test sequence
    initial begin
        // Initialize all inputs
        initialize_signals();
        
        // Test 1: Reset sequence
        test_reset();
        
        // Test 2: One-shot mode
        test_one_shot_mode();
        
        // Test 3: Periodic mode
        test_periodic_mode();
        
        // Test 4: PWM mode
        test_pwm_mode();
        
        // Test 5: Mode change during operation
        test_mode_change_during_operation();
        
        // End simulation
        #1000;
        $display("All tests completed!");
        $stop;
        //$finish;
    end
    
    // Initialize all signals to default values
    task initialize_signals();
        begin
            clk = 0;
            rst_n = 1;
            mode = 2'b00; // Off mode
            prescaler = 16'd0; // No prescaling
            reload_val = 32'd0;
            compare_val = 32'd0;
            start = 0;
            #100;
        end
    endtask
    
    // Test 1: Reset functionality
    task test_reset();
        begin
            $display("=== Test 1: Reset Sequence ===");
            
            // Apply reset
            rst_n = 0;
            #100;
            rst_n = 1;
            #100;
            
            // Verify reset values
            if (current_count === 32'b0 && timeout === 1'b0 && pwm_out === 1'b0) begin
                $display("Reset test PASSED");
            end else begin
                $display("Reset test FAILED");
            end
            #200;
        end
    endtask
    
    // Test 2: One-shot mode
    task test_one_shot_mode();
        begin
            $display("=== Test 2: One-Shot Mode ===");
            
            // Configure for one-shot mode with small count
            mode = 2'b01; // One-shot mode
            reload_val = 32'd5; // Count 5 cycles
            prescaler = 16'd0; // No prescaling
            
            #100;
            start = 1;
            #1000; // Hold start for 1us
            start = 0;
            
            // Wait for timeout
            wait(timeout === 1'b1);
            $display("One-shot timeout detected at time %0t ns", $time);
            
            // Verify timer stops after timeout
            #1000;
            if (current_count === 32'b0) begin
                $display("One-shot test PASSED - Timer stopped after timeout");
            end else begin
                $display("One-shot test FAILED - Timer didn't stop");
            end
            #200;
        end
    endtask
    
    // Test 3: Periodic mode
    task test_periodic_mode();
        begin
            $display("=== Test 3: Periodic Mode ===");
            
            // Configure for periodic mode
            mode = 2'b10; // Periodic mode
            reload_val = 32'd3; // Short period for testing
            start = 1;
            #1000;
            start = 0;
            
            // Wait for first timeout
            wait(timeout === 1'b1);
            $display("First periodic timeout at time %0t ns", $time);
            
            // Wait for second timeout to verify auto-reload
            @(posedge timeout);
            $display("Second periodic timeout at time %0t ns", $time);
            
            // Verify timer continues running
            #500;
            if (current_count > 32'b0) begin
                $display("Periodic test PASSED - Timer continues running");
            end else begin
                $display("Periodic test FAILED - Timer stopped");
            end
            #200;
        end
    endtask
    
    // Test 4: PWM mode
    task test_pwm_mode();
        begin
            $display("=== Test 4: PWM Mode ===");
            
            // Configure for PWM mode
            mode = 2'b11; // PWM mode
            reload_val = 32'd10; // PWM period
            compare_val = 32'd7; // 70% duty cycle (7/10 high)
            start = 1;
            #1000;
            start = 0;
            
            // Let PWM run for a few cycles and observe behavior
            #5000;
            
            // Check if PWM output is toggling
            if (pwm_out !== 1'bX) begin // Not unknown/uninitialized
                $display("PWM test PASSED - PWM output active");
            end else begin
                $display("PWM test FAILED - No PWM output");
            end
            #200;
        end
    endtask
    
    // Test 5: Mode change during operation
    task test_mode_change_during_operation();
        begin
            $display("=== Test 5: Mode Change During Operation ===");
            
            // Start in periodic mode
            mode = 2'b10; // Periodic mode
            reload_val = 32'd5;
            start = 1;
            #1000;
            start = 0;
            
            // Wait for timer to start counting
            #1000;
            
            // Change mode to off while running - should stop immediately
            mode = 2'b00;
            #1000;
            
            if (current_count > 32'b0 && current_count < 32'd5) begin
                $display("Mode change test PASSED - Timer stopped mid-count");
            end else begin
                $display("Mode change test FAILED - Unexpected behavior");
            end
            #200;
        end
    endtask
    
    // Monitor to display important events
    always @(posedge clk) begin
        if (timeout) begin
            $display("Timeout pulse detected at time %0t ns", $time);
        end
        
        if (start) begin
            $display("Start signal asserted at time %0t ns", $time);
        end
    end
    
endmodule
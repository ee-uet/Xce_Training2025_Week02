module tb_multi_mode_timer();
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
    
    // Clock generation (1 MHz)
    initial begin
        clk = 0;
        forever #500 clk = ~clk; // 500ns period for 1MHz clock
    end
    
    // Instantiate the timer
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
    
    // Helper function to interpret mode values
    function string mode_to_string(logic [1:0] mode_val);
        case(mode_val)
            2'b00: return "OFF";
            2'b01: return "ONE-SHOT";
            2'b10: return "PERIODIC";
            2'b11: return "PWM";
            default: return "UNKNOWN";
        endcase
    endfunction
    
    // Synchronous test sequence
    initial begin
        // Initialize VCD dump
        $dumpfile("5.vcd");
        $dumpvars(0, tb_multi_mode_timer);
        
        // Initialize signals
        @(posedge clk);
        rst_n = 0;
        mode = 2'b00;
        prescaler = 16'd1;
        reload_val = 32'd10;
        compare_val = 32'd3;
        start = 0;
        
        // Test 1: Reset
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("Time=%t: Reset - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        // Test 2: One-shot mode
        @(posedge clk);
        mode = 2'b01;
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Time=%t: One-shot started - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        // Wait for timeout and re-enable
        repeat(40) @(posedge clk); // Approx 20000ns at 1MHz
        $display("Time=%t: After timeout - Timeout=%b, Count=%d", $time, timeout, current_count);
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Time=%t: One-shot re-enabled after timeout - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        repeat(3) @(posedge clk);
        
        // Test 3: Periodic mode
        @(posedge clk);
        mode = 2'b10;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Time=%t: Periodic started - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        // Wait for a few cycles
        repeat(100) @(posedge clk); // Approx 50000ns at 1MHz
        $display("Time=%t: Periodic running - Timeout=%b, Count=%d", $time, timeout, current_count);
        
        // Test 4: PWM mode
        @(posedge clk);
        mode = 2'b11;
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Time=%t: PWM started - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        // Wait for a few PWM cycles
        repeat(200) @(posedge clk); // Approx 100000ns at 1MHz
        $display("Time=%t: PWM running - PWM_out=%b, Count=%d", $time, pwm_out, current_count);
        
        // Test 5: Mode change during operation
        @(posedge clk);
        mode = 2'b10; // Back to periodic
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        $display("Time=%t: Mode changed to periodic - Mode=%s, Count=%d", $time, mode_to_string(mode), current_count);
        
        // Wait a bit more
        repeat(100) @(posedge clk); // Approx 50000ns at 1MHz
        $display("Time=%t: Final state - Timeout=%b, Count=%d", $time, timeout, current_count);
        
        // Finish simulation
        @(posedge clk);
        $finish;
    end
    
    // Monitor to display important events
    always @(posedge clk) begin
        $display("Time=%t: clk edge - State=%s, Count=%d, Timeout=%b, PWM=%b", 
                 $time, mode_to_string(mode), current_count, timeout, pwm_out);
    end
endmodule

module multi_mode_timer (
    input  logic        clk,          // 1 MHz system clock
    input  logic        rst_n,        // Active-low reset
    input  logic [1:0]  mode,         // 00=OFF, 01=ONE-SHOT, 10=PERIODIC, 11=PWM
    input  logic [15:0] prescaler,    // Clock divider (for PWM only)
    input  logic [31:0] reload_val,   // Timer reload value
    input  logic [31:0] compare_val,  // For PWM duty cycle
    input  logic        start,        // Start / enable signal
    output logic        timeout,      
    output logic        pwm_out,      
    output logic [31:0] current_count
);

    // Internal signals
    logic [15:0] prescale_cnt; // Prescaler counter for PWM mode
    logic start_d;              // Previous value of start (for rising edge detection)
    logic [31:0] next_count;    // Next counter value for PWM

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all outputs and internal counters
            current_count <= 0;
            prescale_cnt  <= 0;
            timeout       <= 0;
            pwm_out       <= 0;
            start_d       <= 0;
            next_count <= 0;
            
        end else begin
            start_d <= start; // Save previous start for edge detection

            case(mode)
                2'b00: begin
                    // OFF Mode: timer disabled
                    current_count <= 0;
                    timeout       <= 0;
                    pwm_out       <= 0;
                    prescale_cnt  <= 0;

                end

                2'b01: begin
                    // ONE-SHOT Mode: triggered on rising edge of start
                    if (start && !start_d && current_count == 0) begin
                        current_count <= reload_val;
                        timeout <= 0;
                    end else if (current_count > 0) begin
                        current_count <= current_count - 1;
                        timeout <= (current_count == 1) ? 1 : 0; // Set timeout when reaching 0 next cycle
                    end else begin
                        current_count <= 0;
                        timeout <= 0;
                    end
                    pwm_out <= 0;
                    prescale_cnt <= 0;
                end

                2'b10: begin
                    // PERIODIC Mode: auto reload on reaching zero
                    if (start) begin
                        if (current_count == 0)
                            current_count <= reload_val;
                        else
                            current_count <= current_count - 1;

                        timeout <= (current_count == 1) ? 1 : 0;
                    end else begin
                        current_count <= 0;
                        timeout <= 0;
                    end
                    pwm_out <= 0;
                    prescale_cnt <= 0;
                end

                2'b11: begin
                    // PWM Mode
                    if (start) begin
                        if (prescale_cnt < prescaler) begin
                            prescale_cnt <= prescale_cnt + 1; // wait until prescaler counts up
                        end else begin
                            prescale_cnt <= 0;

                            // Compute next counter value
                            if (current_count < reload_val - 1)
                                next_count = current_count + 1;
                            else
                                next_count = 0;

                            // Update counter
                            current_count <= next_count;

                            // PWM output: HIGH while counter < compare_val
                            pwm_out <= (next_count < compare_val) ? 1 : 0;

                            // Timeout flag: HIGH for one clock at end of PWM period
                            timeout <= (next_count == reload_val - 1) ? 1 : 0;
                        end
                    end else begin
                        // Timer stopped: reset outputs
                        current_count <= 0;
                        pwm_out       <= 0;
                        timeout       <= 0;
                        prescale_cnt  <= 0;
                    end
                end

                default: begin
                    // Default safe state
                    current_count <= 0;
                    timeout       <= 0;
                    pwm_out       <= 0;
                    prescale_cnt  <= 0;
                end
            endcase
        end
    end

endmodule

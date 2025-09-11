module multi_mode_timer (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  mode,
    input  logic [15:0] prescaler,
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val,
    input  logic        start,
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);

    logic pre_clk;
    logic [15:0] count;
    logic [1:0]  prev_mode;

   
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count   <= 0;
            pre_clk <= 0;
        end
        else if (count == prescaler-1) begin
            count   <= 0;
            pre_clk <= ~pre_clk;
        end
        else begin
            count <= count + 1;
        end
    end

    
    logic start_d;          // delayed start sampled by pre_clk
    logic start_pulse;      // 1-cycle pulse on start rising edge

    always_ff @(posedge pre_clk or negedge rst_n) begin
        if (!rst_n) begin
            start_d <= 1'b0;
        end else begin
            start_d <= start;
        end
    end

    assign start_pulse = start & ~start_d;

    
    always_ff @(posedge pre_clk or negedge rst_n) begin
        if (!rst_n) begin
            current_count <= 0;
            timeout       <= 1'b0;
            pwm_out       <= 1'b0;
            prev_mode     <= 2'b00;
        end
        else begin
            // reload only when start *edge* or mode changes  (CHANGED)
            if (mode != prev_mode || start_pulse) begin
                current_count <= reload_val;
                timeout       <= 1'b0;
                pwm_out       <= 1'b0; // keep low until PWM computes next cycle
            end
            else begin
                case (mode)
                    2'b01: begin // One-shot
                        pwm_out <= 1'b0; // ensure low outside PWM
                        if (current_count > 0) begin
                            current_count <= current_count - 1;
                            timeout       <= 1'b0;
                        end
                        else begin
                            timeout       <= 1'b1; // stays asserted once reached zero
                        end
                    end

                    2'b10: begin // Periodic
                        pwm_out <= 1'b0; // ensure low outside PWM
                        if (current_count > 0) begin
                            current_count <= current_count - 1;
                            timeout       <= 1'b0;
                        end
                        else begin
                            timeout       <= 1'b1;
                            current_count <= reload_val; // reload automatically
                        end
                    end

                    2'b11: begin // PWM
                        logic [31:0] next_count;

                        // compute next counter value
                        if (current_count > 0) begin
                            next_count = current_count - 1;
                            timeout    <= 1'b0; // FIX: non-blocking
                        end
                        else begin
                            next_count = reload_val;
                            timeout    <= 1'b1; // pulse/level as per your design
                        end

                        // update outputs
                        pwm_out       <= (next_count >= compare_val);
                        current_count <= next_count;
                    end

                    default: begin
                        current_count <= 32'd0;
                        timeout       <= 1'b0;
                        pwm_out       <= 1'b0;
                    end
                endcase
            end

            // update prev_mode
            prev_mode <= mode;
        end
    end

endmodule

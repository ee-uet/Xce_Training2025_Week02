module multi_mode_timer (
    input  logic        clk,         // 1 MHz input clock
    input  logic        rst_n,       // Active-low reset
    input  logic [1:0]  mode,        // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,   // Clock divider
    input  logic [31:0] reload_val,  // Reload/period value
    input  logic [31:0] compare_val, // For PWM duty cycle
    input  logic        start,
    output logic        timeout,     // Timeout/interrupt pulse
    output logic        pwm_out,     // PWM output
    output logic [31:0] current_count,
    output logic        tick_out 
);

    // Internal signals
    logic [15:0] prescaler_cnt;
    logic        tick_en;          // "1" when prescaler expires
    logic [31:0] counter;
    logic        running;

    // Prescaler logic (generates tick_en at divided frequency)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler_cnt <= 16'd0;
            tick_en       <= 1'b0;
        end else if (running) begin
            if (prescaler_cnt == prescaler) begin
                prescaler_cnt <= 16'd0;
                tick_en       <= 1'b1;
            end else begin
                prescaler_cnt <= prescaler_cnt + 1'b1;
                tick_en       <= 1'b0;
            end
        end else begin
            prescaler_cnt <= 16'd0;
            tick_en       <= 1'b0;
        end
    end

    // Main counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0;
            running <= 1'b0;
            timeout <= 1'b0;
            pwm_out <= 1'b0;
        end else begin
            timeout <= 1'b0; // default (pulse on events)

            if (start)
                running <= 1'b1;

            if (!running || mode == 2'b00) begin
                // Off mode
                counter <= 32'd0;
                pwm_out <= 1'b0;
            end else if (tick_en) begin
                unique case (mode)

                    2'b01: begin // One-shot
                        if (counter == 0) begin
                            counter <= counter; // hold
                            running <= 1'b0;    // stop
                            timeout <= 1'b1;    // signal timeout
                        end else begin
                            counter <= counter - 1;
                        end
                    end

                    2'b10: begin // Periodic
                        if (counter == 0) begin
                            counter <= reload_val; // reload
                            timeout <= 1'b1;       // pulse each period
                        end else begin
                            counter <= counter - 1;
                        end
                    end

                    2'b11: begin // PWM
                        if (counter == 0) begin
                            counter <= reload_val; // reload every period
                        end else begin
                            counter <= counter - 1;
                        end
                        // Compare logic: pwm_out high if count > compare_val
                        pwm_out <= (counter > compare_val);
                    end

                    default: begin
                        counter <= 32'd0;
                        pwm_out <= 1'b0;
                    end

                endcase
            end
        end
    end

    // Counter initialization on start
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0;
        end else if (start) begin
            counter <= reload_val; // load initial value
        end
    end

    assign current_count = counter;
    assign tick_out = tick_en;
endmodule


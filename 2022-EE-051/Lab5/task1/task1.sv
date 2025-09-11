module multi_mode_timer (
    input  logic        clk,           // 1 MHz
    input  logic        rst_n,
    input  logic [1:0]  mode,          // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,     // Clock divider
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val,   // For PWM duty cycle
    input  logic        start,
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);

    logic [31:0] counter;
    logic [15:0] presc_cnt;
    logic [1:0]  curr_mode;
    logic        active;

    assign current_count = counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter     <= 0;
            presc_cnt   <= 0;
            timeout     <= 0;
            pwm_out     <= 0;
            curr_mode   <= 2'b00;
            active      <= 0;
        end else begin
            timeout <= 0;

            // START signal
            if (start) begin
                curr_mode <= mode;
                active    <= (mode != 2'b00);
                counter   <= reload_val;
                presc_cnt <= 0;
                pwm_out   <= 0;
            end
            // Mode change during operation
            else if (mode != curr_mode) begin
                curr_mode <= mode;
                if (mode != 2'b00) begin
                    active    <= 1;
                    counter   <= reload_val;
                    presc_cnt <= 0;
                    pwm_out   <= 0;
                end else begin
                    active    <= 0;
                    pwm_out   <= 0;
                end
            end

            // Timer operation
            if (active && curr_mode != 2'b00) begin
                if (prescaler == 0 || presc_cnt >= prescaler) begin
                    presc_cnt <= 0;

                    if (counter > 0)
                        counter <= counter - 1;

                    case (curr_mode)
                        2'b01: begin // ONE-SHOT
                            if (counter == 1) begin
                                timeout   <= 1;
                                active    <= 0;
                                curr_mode <= 2'b00;
                            end
                        end

                        2'b10: begin // PERIODIC
                            if (counter == 1) begin
                                timeout <= 1;
                                counter <= reload_val;
                            end
                        end

                        2'b11: begin // PWM
                            if (counter == 0)
                                counter <= reload_val;

                            if (counter < compare_val)
                                pwm_out <= 1'b1;
                            else
                                pwm_out <= 1'b0;
                        end
                    endcase
                end else begin
                    presc_cnt <= presc_cnt + 1;
                end
            end else begin
                pwm_out <= 0;
            end
        end
    end
endmodule

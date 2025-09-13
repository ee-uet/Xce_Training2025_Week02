module compare_logic (
    input  logic [31:0] current_count,
    input  logic [31:0] compare_value,
    input  logic [1:0]  mode,

    output logic        one_shot,
    output logic        periodic,
    output logic        pwm_mode,
    output logic        off_signal
);

    always_comb begin
        // default values
        one_shot   = 1'b0;
        periodic   = 1'b0;
        pwm_mode   = 1'b0;
        off_signal = 1'b0;

        case (mode)
            2'b01: begin // one-shot mode
                if (current_count == 32'd0) begin
                    one_shot = 1'b1;
                end
            end

            2'b10: begin // periodic mode
                if (current_count == 32'd0) begin
                    periodic = 1'b1;
                end
            end

            2'b11: begin // PWM mode
                if (current_count == compare_value) begin
                    pwm_mode = 1'b1;
                end
            end

            2'b00: begin // off mode
                off_signal = 1'b1;
            end
        endcase
    end

endmodule
// Mode encoding: 00=off, 01=one-shot, 10=periodic, 11=PWM

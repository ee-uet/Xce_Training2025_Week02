module LogicComparater (
    input  logic [31:0] current_count,
    input  logic [31:0] compare_value,
    input  logic [1:0]  mode,
    output logic        one_shot,
    output logic        periodic,
    output logic        pwm_mode,
    output logic        off_signal
);

    always_comb begin
        one_shot    = 0;
        periodic    = 0;
        pwm_mode    = 0;
        off_signal  = 0;

        case (mode)
            2'b01: if (current_count == 32'd0) one_shot = 1;
            2'b10: if (current_count == 32'd0) periodic = 1;
            2'b11: pwm_mode = (current_count < compare_value);
            2'b00: off_signal = 1;
            default: ;
        endcase
    end

endmodule

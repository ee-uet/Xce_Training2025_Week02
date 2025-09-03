module comapre_logic (
    input logic [31:0] current_count,
    input logic [31:0] compare_value,
    input logic [1:0] mode,
    output logic one_shot,
    output logic periodic,
    output logic pwm_mode,
    output logic off_signal

);
always_comb begin 
    one_shot = 0;
    periodic = 0;
    pwm_mode = 0;
    off_signal = 0;
    case (mode)
       2'01: begin
            if (current_count == 32'd0) begin
                one_shot = 1;
            end 
       end
       2'10: begin
            if (current_count == 32'd0) begin
                periodic = 1;
            end 
       end
       2'11: begin
            if (current_count == compare_value) begin
                pwm_mode = 1;
            end 
       end
       2'00: begin
            off_signal = 1;
       end
    endcase

    
end

endmodule
// 00=off, 01=one-shot, 10=periodic, 11=PWM
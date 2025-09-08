module multi_mode_timer (
input logic clk,
// 1 MHz
input logic rst_n,
input timer_mode [1:0] mode,
// 00=off, 01=one-shot, 10=periodic, 11=PWM
input logic [15:0] prescaler, // Clock divider
input logic [31:0] reload_val,
input logic [31:0] compare_val, // For PWM duty cycle
input logic start,
output logic timeout,
output logic pwm_out,
output logic [31:0] current_count
);
// TOD: Implement timer with all modes
logic load;
logic enable;
logic up_down;
logic [7:0] load_value;
logic [7:0] max_count;
logic [7:0] count;
logic zero;
programmable_counter PG(
    .tc(timeout), .*
);
timer_mode curr_mode,next_mode;
// Consider: How to handle mode changes during operation?
always_comb begin 
    case (curr_mode)
        ONE_SHORT:begin
            
        end

        default: 
    endcase
end
endmodule
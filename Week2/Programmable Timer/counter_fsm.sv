typedef enum logic [2:0] {
        IDLE = 2'b00,
        RUNNING = 2'b01,
        ONE_SHOT = 2'b10
        PERIODIC = 2'b11,
        PWM = 2'b100,
        PWN_RUN = 2'b101,
        OFF = 2'b110
    } state_t;


module counter_fsm (
    input logic prescaled_clk,
    input logic reset_n,
    input logic start,
    input logic one_shot,
    input logic periodic,
    input logic pwm_mode,
    input logic off_signal,
    input logic [31: 0] current_count
    output logic enable,
    output logic relaod_signal,
    output logic pwm_signal,
    output logic time_out,
    output logic pwn_out
);

state_t c_state, n_state;
// State transition
always_ff @(posedge prescaled_clk or negedge reset_n) begin
    if (!reset_n) begin
        c_state <= IDLE;
    end else begin
        c_state <= n_state;
    end
end
// Next state logic
always_comb begin
    case (c_state)
        IDLE: begin
            if (start) begin
                n_state <= RUNNING;
            end
            else begin
                n_state <= IDLE;
            end
        end
        RUNNING: begin
            if (one_shot) begin
                n_state <= ONE_SHOT;
            end
            else if (periodic) begin
                n_state <= PERIODIC;
            end
            else if (pwm_mode) begin
                n_state <= PWM;
            end
            else if (off_signal) begin
                n_state <= OFF;
            end
            else begin
                n_state <= RUNNING;
            end
        end
        ONE_SHOT: begin
            n_state <= IDLE;
        end
        PERIODIC: begin
            n_state <= RUNNING;
        end
        PWM: begin
            n_state <= PWN_RUN;
        end
        PWM_RUN: begin
            if (current_count == 32'd0) begin
                n_state <= PERIODIC;
            end
            else begin
                n_state <= PWM_RUN;
            end
        end
        OFF: begin
            if (!off_signal) begin
                n_state <= RUNNING;
            end
            else begin
                n_state <= OFF;
            
            end
        end        
    endcase
end
// Output logic
always_comb begin
    enable = 0;
    relaod_signal = 0;
    pwm_mode = 0;
    time_out = 0;
    pwn_out = 0;
    case (c_state)
        IDLE: begin
            relaod_signal = 1;
        
        end
        RUNNING: begin
            enable = 1;
            
        end
        ONE_SHOT: begin
            relaod_signal = 1;
            time_out = 1;
        
        end
        PERIODIC: begin
            relaod_signal = 1;
            time_out = 1;
        end
        PWM: begin
        
            pwm_signal = 1;
        end
        PWM_RUN: begin
            enable = 1;
            pwn_out = 1;
            pwm_signal = 0;
        end
        OFF: begin
            enable = 0;
            relaod_signal = 0;
            pwm_signal = 0;
        end
            



    endcase
end


endmodule// 00=off, 01=one-shot, 10=periodic, 11=PWM
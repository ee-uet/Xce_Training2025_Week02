/* Implementation of a Programmable Timer */
module top_module (
    input logic         clk,
    input logic         reset_n,
    input logic         start,
    input logic [1:0]   mode, // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input logic [15:0]  prescale_val, 
    input logic [31:0]  reload_value, 
    input logic [31:0]  compare_value, 
    output logic        time_out, 
    output logic        pwn_out 
);
logic           prescaled_clk;
logic           enable;
logic           relaod_signal;
logic           pwm_signal;
logic [31:0]    current_count;
logic           one_shot;
logic           periodic;
logic           pwm_mode;
logic           off_signal;

// Instantiating Prescaler 
Prescaler prescaler_inst (
    .clk(clk),
    .reset_n(reset_n),
    .prescale_val(prescale_val),
    .prescaled_clk(prescaled_clk)
);
// Instantiating FSM
counter_fsm counter_fsm_inst (
    .clk(prescaled_clk),
    .reset_n(reset_n),
    .start(start),
    .one_shot(one_shot),
    .periodic(periodic),
    .pwm_mode(pwm_mode),
    .off_signal(off_signal),
    .current_count(current_count),
    .enable(enable),
    .relaod_signal(relaod_signal),
    .pwm_signal(pwm_signal),
    .time_out(time_out),
    .pwn_out(pwn_out)
);
// Instantiating Down Counter
down_counter down_counter_inst (
    .prescaled_clk(prescaled_clk),
    .enable(enable),
    .relaod_signal(relaod_signal),
    .pwm_signal(pwm_signal),
    .relaod_value(reload_value),
    .compare_value(compare_value),
    .current_count(current_count)
);
// Instantiating Compare Logic
comapre_logic compare_logic_inst (
    .current_count(current_count),
    .compare_value(compare_value),
    .mode(mode),
    .one_shot(one_shot),
    .periodic(periodic),
    .pwm_mode(pwm_mode),
    .off_signal(off_signal)
);

    
    
endmodule
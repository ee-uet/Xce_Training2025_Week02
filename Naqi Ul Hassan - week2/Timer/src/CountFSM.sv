typedef enum logic [2:0] {
    IDLE      = 3'b000,
    RUNNING   = 3'b001,
    ONE_SHOT  = 3'b010,
    PERIODIC  = 3'b011,
    PWM       = 3'b100,
    PWM_RUN   = 3'b101,
    OFF       = 3'b110
} state_t;

module CountFSM (
    input  logic         prescaled_clk,
    input  logic         reset_n,
    input  logic         start,
    input  logic         one_shot,
    input  logic         periodic,
    input  logic         pwm_mode,
    input  logic         off_signal,
    input  logic [31:0]  current_count,
    output logic         enable,
    output logic         reload_signal,
    output logic         pwm_signal,
    output logic         timeout
);

    state_t c_state, n_state;

    always_ff @(posedge prescaled_clk or negedge reset_n) begin
        if (!reset_n)
            c_state <= IDLE;
        else
            c_state <= n_state;
    end

    always_comb begin
        n_state = c_state;
        case (c_state)
            IDLE: if (start) n_state = RUNNING;
            RUNNING: begin
                if (one_shot)       n_state = ONE_SHOT;
                else if (periodic)  n_state = PERIODIC;
                else if (pwm_mode)  n_state = PWM;
                else if (off_signal)n_state = OFF;
            end
            ONE_SHOT:  n_state = IDLE;
            PERIODIC:  n_state = RUNNING;
            PWM:       n_state = PWM_RUN;
            PWM_RUN:   if (current_count == 32'd0) n_state = PWM;
            OFF:       if (!off_signal) n_state = RUNNING;
            default:   n_state = IDLE;
        endcase
    end

    always_comb begin
        enable        = 0;
        reload_signal = 0;
        timeout       = 0;
        pwm_signal    = 0;

        case (c_state)
            IDLE:        reload_signal = 1;
            RUNNING:     enable = 1;
            ONE_SHOT: begin
                enable        = 1;
                timeout       = (current_count==0);
                reload_signal = 1;
            end
            PERIODIC: begin
                enable        = 1;
                timeout       = (current_count==0);
                reload_signal = (current_count==0);
            end
            PWM:       reload_signal = 1;
            PWM_RUN: begin
                enable     = 1;
                pwm_signal = 1;
            end
            OFF: begin end
        endcase
    end

endmodule

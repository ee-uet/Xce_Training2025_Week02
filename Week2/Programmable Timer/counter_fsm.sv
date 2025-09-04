typedef enum logic [2:0] {
    IDLE     = 3'b000,
    RUNNING  = 3'b001,
    ONE_SHOT = 3'b010,
    PERIODIC = 3'b011,
    PWM      = 3'b100,
    PWM_RUN  = 3'b101,
    OFF      = 3'b110
} state_t;


module counter_fsm (
    input  logic        prescaled_clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic        one_shot,
    input  logic        periodic,
    input  logic        pwm_mode,
    input  logic        off_signal,
    input  logic [31:0] current_count,

    output logic        enable,
    output logic        reload_signal,
    output logic        pwm_signal,
    output logic        time_out,
    output logic        pwm_out
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
        n_state = c_state;
        case (c_state)
            IDLE: begin
                if (start)          n_state = RUNNING;
            end
            RUNNING: begin
                if (one_shot)       n_state = ONE_SHOT;
                else if (periodic)  n_state = PERIODIC;
                else if (pwm_mode)  n_state = PWM;
                else if (off_signal)n_state = OFF;
            end
            ONE_SHOT:   n_state = IDLE;
            PERIODIC:   n_state = RUNNING;
            PWM:        n_state = PWM_RUN;
            PWM_RUN: begin
                if (current_count == 32'd0)
                    n_state = PERIODIC;
            end
            OFF: begin
                if (!off_signal)    n_state = RUNNING;
            end
        endcase
    end

    // Output logic
    always_comb begin
        enable        = 1'b0;
        reload_signal = 1'b0;
        pwm_signal    = 1'b0;
        time_out      = 1'b0;
        pwm_out       = 1'b0;

        case (c_state)
            IDLE: begin
                reload_signal = 1'b1;
            end
            RUNNING: begin
                enable = 1'b1;
            end
            ONE_SHOT: begin
                reload_signal = 1'b1;
                time_out      = 1'b1;
            end
            PERIODIC: begin
                reload_signal = 1'b1;
                time_out      = 1'b1;
            end
            PWM: begin
                pwm_signal = 1'b1;   // initialize PWM
            end
            PWM_RUN: begin
                enable     = 1'b1;   // counter keeps running
                pwm_out    = 1'b1;   // active PWM output
                pwm_signal = 1'b0;   // no reload in run state
            end
            OFF: begin
                enable        = 1'b0;
                reload_signal = 1'b0;
                pwm_signal    = 1'b0;
            end
        endcase
    end

endmodule

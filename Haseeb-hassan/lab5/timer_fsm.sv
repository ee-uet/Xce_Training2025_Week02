typedef enum logic [2:0] {
    OFF      = 3'b000,
    LOAD     = 3'b001,
    RUN      = 3'b010,
    TIMEOUT  = 3'b011,
    RELOAD   = 3'b100
} state_t;

module timer_fsm (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic        counter_zero,
    input  logic [1:0]  mode,         // 01=one-shot, 10=periodic, 11=PWM

    output logic        prescaler_enable,
    output logic        cnt_load,
    output logic        cnt_enable,
    output logic        cnt_reload_on_zero
);

    state_t current_state, next_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= OFF;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = current_state; // default

        case(current_state)
            OFF:    if (start) next_state = LOAD;
            LOAD:   next_state = RUN;
            RUN:    if (counter_zero) begin
                        if (mode == 2'b01) next_state = TIMEOUT;
                        else                next_state = RELOAD;
                    end
            RELOAD: next_state = RUN;
            TIMEOUT: next_state = OFF;
            default: next_state = OFF;
        endcase
    end

    // Output logic
    always_comb begin
        prescaler_enable   = 0;
        cnt_load           = 0;
        cnt_enable         = 0;
        cnt_reload_on_zero = 0;

        case(current_state)
            OFF: begin
                prescaler_enable   = 0;
                cnt_load           = 0;
                cnt_enable         = 0;
                cnt_reload_on_zero = 0;
            end
            LOAD: begin
                cnt_load       = 1;
                prescaler_enable = 0;
                cnt_enable     = 0;
                cnt_reload_on_zero = 0;
            end
            RUN: begin
                prescaler_enable   = 1;
                cnt_enable         = 1;
                cnt_reload_on_zero = (mode != 2'b01); // reload only for periodic/PWM
            end
            RELOAD: begin
                cnt_load           = 1;
                cnt_reload_on_zero  = 1;
            end
            TIMEOUT: begin
                prescaler_enable   = 0;
                cnt_enable         = 0;
            end
        endcase
    end
endmodule

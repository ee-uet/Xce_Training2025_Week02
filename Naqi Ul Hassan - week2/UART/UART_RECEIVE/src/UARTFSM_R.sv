typedef enum logic [1:0] {
    IDLE        = 2'b00,
    START       = 2'b01,
    CHECK_ERROR = 2'b10
} state_t;

module UARTFSM_R (
    input  logic div_clk,
    input  logic rst_n,
    input  logic rx_serial,
    input  logic zero_detected,
    input  logic count_done,
    output logic start_check,
    output logic start_count,
    output logic start_shift,
    output logic rx_ready,
    output logic rx_busy
);

state_t c_state, n_state;

// State register
always_ff @(posedge div_clk or negedge rst_n) begin
    if (!rst_n)
        c_state <= IDLE;
    else
        c_state <= n_state;
end

// Next state logic
always_comb begin
    n_state = c_state;
    case (c_state)
        IDLE: 
            if (zero_detected) n_state = START;
        START: 
            if (count_done) n_state = CHECK_ERROR;
        CHECK_ERROR: 
            n_state = IDLE;
    endcase
end

// Output logic
always_comb begin
    start_count  = 0;
    start_shift  = 0;
    start_check  = 0;
    rx_ready     = 0;
    rx_busy      = 0;

    case (c_state)
        IDLE: begin
            if (zero_detected) begin
                rx_busy     = 1;
                start_count = 1;
                start_shift = 1;
            end else begin
                rx_ready = 1;
            end
        end
        START: begin
            rx_busy     = 1;
            start_count = 1;
            start_shift = 1;
        end
        CHECK_ERROR: begin
            start_check = 1;
            rx_busy     = 0; // Frame done
            rx_ready    = 1; // New byte can be accepted
        end
    endcase
end

endmodule

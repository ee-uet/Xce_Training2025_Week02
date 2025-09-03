typedef enum logic [1:0] {
    IDLE = 2'b00,
    START = 2'b01,
    CHECK_ERROR = 2'b10,

} state_t;


module uart_rx_fsm (
    input logic div_clk,
    input logic rst_n,
    input logic rx_serial,
    input logic zero_detected,
    input logic count_done,
    input logic start_check,
    output logic start_count,
    output logic start_shift,
    output logic rx_ready,
    output logic rx_busy
    
);
state_t c_state, n_state;
//state register
always_ff @(posedge div_clk) begin
    if (!rst_n) begin
        c_state <= IDLE;
    end else begin
        c_state <= n_state;
    end
end
//next state logic
always_comb begin
    case (c_state)
        IDLE: begin
            if (zero_detected) begin
                n_state = START;
            end else begin
                n_state = IDLE;
            end
        end
        START: begin
            if (count_done) begin
                n_state = CHECK_ERROR;
            end else begin
                n_state = START;
            end
        end
        CHECK_ERROR: begin
            n_state = IDLE;
        end

    endcase
end
//output logic
always_comb begin
    rx_busy = 0;
    start_count = 0;
    start_shift = 0;
    rx_ready = 0;
    case (c_state)
        IDLE: begin
            rx_ready = 1;
        end
        START: begin
            rx_busy = 1;
            start_count = 1;
            start_shift = 1;
        end
        CHECK_ERROR: begin
            start_check = 1;
            rx_busy = 1;
        end

        
    endcase
end



endmodule
typedef enum logic [2:0] {
    IDLE = 3'b000,
    LOAD = 3'b001,
    START_BIT = 3'b010,
    DATA_BITS = 3'b011,
    STOP_BIT = 3'b100
} state_t; 


module uart_tx_fsm (
    input logic div_clk,
    input logic rst_n,
    input logic tx_valid,
    input logic count_done,
    output logic load,
    output logic start_shift,
    output logic start_count,
    output logic start,
    output logic tx_ready,
    output logic tx_busy
);
state_t c_state, n_state;

always_ff @(posedge div_clk) begin
    if (!rst_n ) begin
        c_state <= IDLE;
    end else begin
        c_state <= n_state;
    end
end
// Next state logic
always_comb begin
    unique case (c_state)
        IDLE: begin
            if (tx_valid) begin
                n_state = LOAD;
            end else begin
                n_state = IDLE;
            end
        end
        LOAD: begin
            n_state = START_BIT;
        end
        START_BIT: begin
            n_state = DATA_BITS;
        end
        DATA_BITS: begin
            if (count_done) begin
                n_state = STOP_BIT;
            end else begin
                n_state = DATA_BITS;
            end
        end
        STOP_BIT: begin
            n_state = IDLE;
        end

    endcase
end

endmodule
// Output logic
always_comb begin
    // Default values
    load = 0;
    start_shift = 0;
    start_count = 0;
    start = 0;
    tx_ready = 0;
    tx_busy = 0;

    unique case (c_state)
        IDLE: begin
            if (tx_valid) begin
                tx_ready = 0;
                load = 1;
                tx_busy = 1;
            end else begin
                tx_ready = 1;
            end
            
        end
        LOAD: begin
            start = 1;
            tx_busy = 1;
            
        end
        START_BIT: begin
            start_count = 1;
            start_shift = 1;
            tx_busy = 1;
        end
        DATA_BITS: begin
            if (!count_done) begin
                start_shift = 1;
                start_count = 1;
                tx_busy = 1;
            end
            else begin
                start_shift = 0;
                start_count = 0;
                tx_busy = 1;
            end

            
        end
        STOP_BIT: begin
            tx_busy = 1;
        end
        
            

    endcase
end
module controller(
    input  logic clk,
    input  logic rst,       // active-low reset
    input  logic rx_ready,    // from UART RX
    input  logic f_empty,     // FIFO empty
    input  logic f_full,      // FIFO full
    input  logic done_shifting, // UART shift reg done
    output logic rx_valid
);

    // FSM States
    typedef enum logic [1:0] {IDLE, LOAD_IN_FIFO, DATA_OUT} state_t;
    state_t state, next_state;

    // FSM sequential block
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM next state logic
    always_comb begin
        next_state = state; // default
        case(state)
            IDLE: begin
                if (done_shifting && !f_full)
                    next_state = LOAD_IN_FIFO;
            end

            
            LOAD_IN_FIFO: begin
                // ek cycle ke liye FIFO write enable hoga
                next_state = DATA_OUT;
            end

            DATA_OUT: begin
                if (!f_empty)
                    next_state = DATA_OUT; // read karte raho
                else if (f_empty)
                    next_state = IDLE;     // FIFO khali ho gaya
            end
        endcase
    end

    // Output logic
    always_comb begin
        rx_valid = 0; // default
        case(state)
            IDLE:        rx_valid = 0;
            LOAD_IN_FIFO:rx_valid = 0;
            DATA_OUT:    rx_valid = 1;
        endcase
    end

endmodule

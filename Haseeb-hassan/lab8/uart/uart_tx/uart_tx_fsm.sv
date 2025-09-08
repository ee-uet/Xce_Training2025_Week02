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
    logic tx_start;

    // State register with async reset
    always_ff @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            c_state <= IDLE;
        end
        else begin
            c_state <= n_state;
        end
    end
    always_comb begin : blockName
        if (tx_valid && (c_state == IDLE)) begin
            tx_start = 1'b1;  // Latch the request
        end
        else if (c_state == STOP_BIT) begin
            tx_start = 1'b0;  // Clear when done
        end 
        else begin
            tx_start = tx_start; // Hold the value
        end
    end
    // Next state logic
    always_comb begin
        unique case (c_state)
            IDLE: begin
                if (tx_start) begin
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
            default: n_state = IDLE;
        endcase
    end

    // Output logic (Mealy FSM)
    always_comb begin
        // Default values
        load = 1'b0;
        start_shift = 1'b0;
        start_count = 1'b0;
        start = 1'b0;
        tx_ready = 1'b0;
        tx_busy = 1'b0;

        unique case (c_state)
            IDLE: begin
                tx_ready = 1'b1;
                tx_busy = 1'b0;
                // if (tx_valid) begin
                 //   load = 1'b1;        // Load data when valid asserted
                   // tx_busy = 1'b1;
                   // tx_ready = 1'b0;
               // end
            end
            
            LOAD: begin
                load = 1'b1;
                tx_busy = 1'b1;
                start = 1'b1;           // Output start bit
                
            end
            
            START_BIT: begin
                tx_busy = 1'b1;
                start_shift= 1'b1;           // Continue outputting start bit
                start_count = 1'b1; // Continue counting
                end 
            
            
            DATA_BITS: begin

                if (!count_done) begin
                    start_count = 1'b1; // Continue counting
                    start_shift = 1'b1; // Continue shifting
                    tx_busy = 1'b1;
                end else begin
                    start_count = 1'b0; // Restart counter for stop bit
                    start_shift = 1'b0;
                    tx_busy = 1'b1;
                end
            end
            
            STOP_BIT: begin
                tx_busy = 1'b1;
            end
            
            default: begin
                tx_ready = 1'b1;
                tx_busy = 1'b0;
            end
        endcase
    end

endmodule




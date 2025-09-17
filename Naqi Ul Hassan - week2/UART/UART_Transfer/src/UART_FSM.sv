typedef enum logic [2:0] {
    IDLE      = 3'b000,
    LOAD      = 3'b001,
    START_BIT = 3'b010,
    DATA_BITS = 3'b011,
    STOP_BIT  = 3'b100
} state_t; 

module UART_FSM (
    input  logic div_clk,
    input  logic rst_n,
    input  logic tx_valid,      // request to send data
    input  logic count_done,    // counter signals 8 bits done

    output logic load,          // load data into shift register
    output logic start_shift,   // shift enable
    output logic start_count,   // enable counter
    output logic start,         // drive start bit
    output logic tx_ready,      // ready for new data
    output logic tx_busy        // transmitter is busy
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
        unique case (c_state)
            IDLE:      n_state = (tx_valid) ? LOAD : IDLE;
            LOAD:      n_state = START_BIT;
            START_BIT: n_state = DATA_BITS;
            DATA_BITS: n_state = (count_done) ? STOP_BIT : DATA_BITS;
            STOP_BIT:  n_state = IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        // defaults
        load        = 0;
        start_shift = 0;
        start_count = 0;
        start       = 0;
        tx_ready    = 0;
        tx_busy     = 0;

        unique case (c_state)
            IDLE: begin
                tx_ready = 1;  // accept new data
            end
            LOAD: begin
                load    = 1;   // load shift register
                tx_busy = 1;
            end
            START_BIT: begin
                start       = 1;   // output start bit
                start_count = 1;   // begin counting baud cycles
                tx_busy     = 1;
            end
            DATA_BITS: begin
                start_shift = 1;   // shift data bits
                start_count = 1;   // keep counter running
                tx_busy     = 1;
            end
            STOP_BIT: begin
                // here you’d send stop bit (handled by datapath → tx_serial = 1)
                tx_busy = 1;
            end
        endcase
    end
endmodule

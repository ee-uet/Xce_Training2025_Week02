module rx_controller #(
    parameter DATA_BITS = 8,
    parameter SAMPLES_PER_BIT = 16   // oversampling (16x typical)
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    input  logic tick_rx,          // oversampling tick

    output logic start_sample_tick, // goes high after 8 ticks (middle of start bit)
    output logic data_sample_tick,  // goes high every 16 ticks (middle of each data bit)
    output logic shift_en,          // enables shift in datapath
    output logic frame_error,
    output logic data_valid,
	output logic write
);

    // FSM states
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state, next_state;

    // Counters
    logic [$clog2(SAMPLES_PER_BIT):0] sample_count;
    logic [$clog2(DATA_BITS):0] bit_count;

   
    // FSM sequential
    always_ff @(posedge clk or posedge rst) begin
        if (!rst) begin
            state        <= IDLE;
            sample_count <= 0;
            bit_count    <= 0;
            data_valid   <= 0;
        end else if (tick_rx) begin
            state <= next_state;

            // sample counter
            if (state == START || state == DATA || state == STOP)
                sample_count <= (sample_count == SAMPLES_PER_BIT-1) ? 0 : sample_count + 1;
            else
                sample_count <= 0;

            // bit counter
            if (state == DATA && data_sample_tick)
                bit_count <= bit_count + 1;
            else if (state == IDLE || state	== STOP)
                bit_count <= 0;

            // data valid flag and write_fifo
            if (state == STOP ) begin
                data_valid <= 1;
			end
            else begin
                data_valid <= 0;
			end
        end
    end

    // FSM combinational
    always_comb begin
        next_state  = state;
        frame_error = 0;

        case (state)
            IDLE: begin
                if (rx == 1'b0)   // detect start bit falling edge
                    next_state = START;
            end

            START: begin
                if (start_sample_tick) begin
                    if (rx == 1'b0)
                        next_state = DATA;
                    else
                        next_state = IDLE; // false start
                end
            end

            DATA: begin
                if (bit_count == DATA_BITS && (sample_count == SAMPLES_PER_BIT-1) )
                    next_state = STOP;
				else 
					next_state = DATA;
            end

            STOP: begin
                if (sample_count == (SAMPLES_PER_BIT - 1)) begin
					if (rx == 1'b1) begin
                        next_state = IDLE;   // valid stop bit
						end
                end
            end
			default : next_state = IDLE;
        endcase
    end
	
	 // Control signals
    assign start_sample_tick = (state == START  && tick_rx && sample_count == (SAMPLES_PER_BIT/2));
    assign data_sample_tick  = (state == DATA   && tick_rx && sample_count == (SAMPLES_PER_BIT/2));
    assign shift_en          = (state == DATA   && data_sample_tick);
	assign write			 = ((state == STOP)	&&	tick_rx && (sample_count == SAMPLES_PER_BIT/2)) ? 1 : 0;

endmodule

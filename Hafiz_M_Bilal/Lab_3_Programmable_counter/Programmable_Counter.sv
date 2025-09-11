// Programmable Counter with FSM
module Programmable_Counter(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load,
    input  logic        enable,
    input  logic        up_down,
    input  logic [7:0]  load_value,
    input  logic [7:0]  max_count,
    output logic [7:0]  count,
    output logic        tc,          // Terminal count
    output logic        zero
);
	// TODO: Implement counter logic
    // Consider: What happens when max_count changes during operation?
    
    // FSM current_states
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        COUNT_UP,
        COUNT_DOWN
    } state_t;

    state_t current_state, next_state;

    // Sequential current_state transition
    always_ff @(posedge clk or negedge rst_n) begin
		// Reset condition
        if (!rst_n) begin
            current_state <= IDLE;
            count <= 8'd0;
        end
        else begin
            current_state <= next_state;

            case (current_state)
                IDLE: begin
                    count <= 8'd0;
                end

                LOAD: begin
                    // Clamp load_value if greater than max_count
					// Ensure load_value is not greater than max_count
                    // Load operation
					if (load_value <= max_count)
                        count <= load_value;
                    else
                        count <= max_count;
                end
				
				// Up-counting (up_down = 1)
                COUNT_UP: begin
                    if (count >= max_count)
                        count <= 8'd0;
                    else
                        count <= count + 1;
                end
				
				// Down-counting (up_down = 0)
                COUNT_DOWN: begin
                    if (count == 0)
                        count <= max_count;
                    else
                        count <= count - 1;
                end
            endcase

            // Handle runtime change of max_count
            if (count > max_count)
                count <= max_count;
        end
    end

    // Next current_state logic
	// next_state decision
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (load)
                    next_state = LOAD;
                else if (enable && up_down)
                    next_state = COUNT_UP;
                else if (enable && !up_down)
                    next_state = COUNT_DOWN;
                else
                    next_state = IDLE;
            end

            LOAD: begin
                if (enable && up_down)
                    next_state = COUNT_UP;
                else if (enable && !up_down)
                    next_state = COUNT_DOWN;
                else
                    next_state = LOAD;
            end

            COUNT_UP: begin
                if (!enable)
                    next_state = IDLE;
                else if (load)
                    next_state = LOAD;
                else if (!up_down)
                    next_state = COUNT_DOWN;
                else
                    next_state = COUNT_UP;
            end

            COUNT_DOWN: begin
                if (!enable)
                    next_state = IDLE;
                else if (load)
                    next_state = LOAD;
                else if (up_down)
                    next_state = COUNT_UP;
                else
                    next_state = COUNT_DOWN;
            end
			
            default: next_state = IDLE;
        endcase
    end

    // Outputs
	
	// assert when count == 0
    assign zero = (count == 8'd0);
	
	// Terminal count: 
    // For up-counting, assert when count == max_count
    // For down-counting, assert when count == 0
    assign tc   = (up_down && (count == max_count)) ||
                  (!up_down && (count == 8'd0));

endmodule

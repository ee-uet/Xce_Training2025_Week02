module multi_mode_timer (
    input  logic        clk,         // 1 MHz
    input  logic        rst_n,
    input  logic [1:0]  mode,        // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,   // Clock divider
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val, // For PWM duty cycle
    input  logic        start,
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);

	// TODO: Implement timer with all modes
	// Consider: How to handle mode changes during operation?
    
    	bit div_of;
    	logic [15:0] clk_div;
    	
    	always_ff @(posedge clk or negedge rst_n) begin
    		if(~rst_n) begin
    			clk_div 	<= #1 0;
    		end else if (div_of) begin
    			clk_div		<= #1 0;
    		end else begin
    			clk_div		<= #1 clk_div + 1;
    		end
    	end
    	
    	assign div_of 	= (clk_div == prescaler);
    	assign timeout	= (current_count == 0);
    	
	typedef enum logic [1:0] {	PWM = 2'b11,
					LOAD = 2'b00,
					ONE_SHOT = 2'b01,
					PERIODIC = 2'b10
					} state_t;
	
	state_t curr_state, next_state;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			curr_state 	<= #1 LOAD;
		end else begin
			curr_state <= #1 next_state;
		end
	end
    
    
    	logic counter_en, counter_load;
    	always_ff @(posedge clk or negedge rst_n) begin
    		if(~rst_n) begin
    			current_count <= #1 ~(0);
    		end else begin
			if(counter_load) begin
				current_count	<= #1 reload_val;
			end else if (counter_en & ~div_of) begin
				current_count	<= #1 current_count - 1;
			end
    		end
    	end
    	
    	always_comb begin
    	
    		pwm_out		= 0;
    		next_state 	= curr_state;
		
    		case(curr_state)
    			LOAD: begin
    				counter_en	= 0;
    				counter_load 	= 1;
    				case({start, mode})
    					3'b101: next_state = ONE_SHOT;
    					3'b110: next_state = PERIODIC;
    					3'b111: next_state = PWM;
					default: next_state = LOAD;
    				endcase
    			end
    			ONE_SHOT: begin
    				counter_load	= 0;
    				counter_en 	= (timeout) ? 0 : 1;
    				if(timeout | (curr_state != mode)) begin next_state = LOAD; end
    			end
    			PERIODIC: begin
    				counter_load	= (timeout) ? 1 : 0;
    				counter_en 	= (timeout) ? 0 : 1;
    				if(curr_state != mode) begin next_state = LOAD; end
    			end
    			PWM: begin
    				counter_load		= (timeout) ? 1 : 0;
    				counter_en 		= (timeout) ? 0 : 1;
    				pwm_out			= (current_count > compare_val) ? 0 : 1;
    				if(curr_state != mode) begin next_state = LOAD; end
    			end
    		endcase
    	end
    	
endmodule


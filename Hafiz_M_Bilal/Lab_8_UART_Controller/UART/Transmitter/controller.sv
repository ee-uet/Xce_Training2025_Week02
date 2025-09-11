module controller(
		input logic clk, rst, tick_tx, empty, load_done, transmit_done,
		output logic tx_start, load, tx_done, rd_en);
	
	typedef enum logic [1:0] {
			IDLE,
			LOAD,
			TRANSMIT
	} state_t;
	
	state_t state, next_state;
	
	always_ff @(posedge clk or negedge rst)
	begin
		if(!rst)
			state <= IDLE;
		else 
			state <= next_state;
	end
	
	always_comb begin
	case(state)
	
	IDLE: begin
			if (!empty && tick_tx) 
				next_state = LOAD;
			else 
				next_state = IDLE;
		end
	LOAD: begin
			if (load_done)
				next_state = TRANSMIT;
			else 
				next_state = LOAD;
			
		end
	TRANSMIT: begin
			if (transmit_done)
				next_state = IDLE;
			else 
				next_state = TRANSMIT;
			end
	default: next_state = IDLE;
	endcase
	
	end
	
	always_comb begin
	
	case(state)
	
	IDLE: {tx_start, load, tx_done, rd_en} = {1'b1, 1'b0, 1'b0, 1'b0};
	LOAD: {tx_start, load, tx_done, rd_en} = {1'b0, 1'b1, 1'b0, ~load_done};	
	TRANSMIT: {tx_start, load, tx_done, rd_en} = {1'b1, 1'b0, 1'b1, 1'b0};
	
	default: {tx_start, load, tx_done, rd_en} = {1'b1, 1'b0, 1'b0, 1'b0};
	
	endcase
	
	end
endmodule


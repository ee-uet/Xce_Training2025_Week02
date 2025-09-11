//Multi-Mode Timer
module Multi_Mode_Timer(
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
	
	logic tick; 			// for Main counter driver
	logic [15:0] psc_cnt; 	// prescaler counter
	
	// Prescaler logic: generates a tick based on prescaler value
    always_ff @(posedge clk) begin
		if(!rst_n) begin
			psc_cnt <= 16'b0; 
			tick <= 1'b0; 
		end
		else if (start) begin
			if(psc_cnt >= prescaler) begin
				psc_cnt <= 16'b0;
				tick <= 1'b1; // Generate one tick
			end
			else begin
				psc_cnt <= psc_cnt + 1;
				tick <= 1'b0;
			end
		end
		else begin
			psc_cnt <= 16'b0;
			tick <= 1'b0;
		end
	end
	
	// Main timer counter logic
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			current_count <= reload_val; // Initialize counter with reload value
		end
		
		else if (start) begin
			if (tick) begin
				case (mode) 
				// Mode 00: Timer off
					2'b00: 	begin
							current_count <= 32'b0;
						end
						
				// Mode 01: One-shot
                // Counts down once, then stays at 0
					2'b01:	begin
							if(current_count == 32'b0) begin
								current_count <= 32'b0;
							end
							else begin
								current_count <= current_count - 1;
							end
						end
				
				// Mode 10: Periodic
                // Reloads automatically after reaching 0
					2'b10:	begin
							if(current_count == 32'b0) begin
								current_count <= reload_val;
							end
							else begin
								current_count <= current_count - 1;
							end
						end
						
				// Mode 11: PWM
                // Drives PWM output
					2'b11:	begin
							if((current_count == 32'b0)) begin
								current_count <= reload_val;
							end
							else begin
								current_count <= current_count - 1;
							end
						end
					default: begin
							current_count <= current_count;
						end
				endcase	
			end
			else begin
				current_count <= current_count;
			end
		end
		
		else begin
			current_count <= current_count;
		end
		
	end	
	
	// PWM output:
    // - Active in PWM mode
    // - High when current_count <= compare_val (duty cycle control)
	assign pwm_out = ((mode == 2'b11) && (current_count <= compare_val));
	
	// Timeout flag:
    // - Active in any mode except "Off"
    // - Asserted when counter reaches 0
	assign timeout = ((mode != 2'b00) && (current_count == 32'b0));
	
endmodule


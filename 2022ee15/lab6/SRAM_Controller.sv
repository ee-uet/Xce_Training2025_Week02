// Define state enumeration
typedef enum logic [1:0] {
    IDLE  = 2'b00,
    READ  = 2'b01,
	WRITE = 2'b10
    // TODO: Add more states
}state_t;

module SRAM_Controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req, 
    input  logic        write_req,
    input  logic [14:0] address, // where data whould be stored in SRAM
    input  logic [15:0] write_data, // This Data is written in SRAM
    output logic [15:0] read_data, // Data from SRAM
    output logic        ready,
    
    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n

);

    state_t current_state, next_state;
	logic [15:0] write_data_buffer;
	logic [15:0] read_data_buffer;
	
    // State register - ALWAYS separate this
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			read_data_buffer <= 16'b0;
		end
		else if (!sram_ce_n && !sram_oe_n && sram_we_n) begin
			read_data_buffer <= sram_data;
		end
	end

    // Next state logic - ALWAYS use always_comb
    always_comb begin
        next_state = current_state; // Default assignment prevents latches
        sram_ce_n  = 1;  
        sram_oe_n  = 1;
        sram_we_n  = 1;
        ready      = 0;
        sram_addr  = address;
        write_data_buffer = write_data;
		read_data = read_data_buffer;
		
        case (current_state)
            // TODO: Implement state transitions
			IDLE: begin
				if(read_req) begin
					next_state = READ;
				end
				else if(write_req) begin
					next_state = WRITE;
				end
				else begin
					next_state = IDLE;
				end
			end
			
			READ: begin
				// These outputs are active low
				sram_ce_n = 0;  // chip enable active
                sram_oe_n = 0;  // output enable(SRAM output)
                sram_we_n = 1;  // read enable
                ready     = 1;
                next_state = IDLE;
			end
			
			WRITE: begin
				// These outputs are active low
				sram_ce_n = 0;  // chip enable active
                sram_oe_n = 1;  // output disable(SRAM output)
                sram_we_n = 0;  // write enable
                ready     = 1;
                next_state = IDLE;
				
			end
			default: begin
				next_state = IDLE;
			end
	    endcase
    end
    
	
    // Output logic - Separate from state logic
    // TODO: Implement Moore or Mealy outputs
	// Tri-state driver
    assign sram_data = (!sram_ce_n && sram_oe_n && !sram_we_n) ? write_data_buffer : 16'hzzzz;
	
endmodule


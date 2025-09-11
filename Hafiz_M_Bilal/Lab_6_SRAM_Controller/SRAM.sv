// Simple SRAM Model (32K x 16-bit memory)
module SRAM(
	input logic 		clk,
    input logic 		rst_n,
    inout wire  [15:0]  sram_data, 
    input logic        	sram_ce_n, // Chip Enable
    input logic        	sram_oe_n, // Output Enable
    input logic        	sram_we_n, // Write Enable
	input logic [14:0] 	sram_addr 

);
	 // Internal memory
	logic [15:0] RAM [0:32767];
	
	// Buffers for write and read operations
	logic [15:0] write_data_buffer;
	logic [15:0] read_data_buffer;
    
	// Capture data from bus during write operation
	assign write_data_buffer = (!sram_ce_n && !sram_we_n && sram_oe_n) ? sram_data : 16'b0;
	
	// Write to RAM or reset contents
	integer i;
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			for(i = 0; i < 15; i++) begin
				RAM[i] <= 16'b0;
				RAM[15] <= 16'h1122;
			end
		end
		// Write cycle
		else if(!sram_ce_n && !sram_we_n && sram_oe_n) begin
			RAM[sram_addr] <= write_data_buffer;
		end
	end
	

	// Read cycle
    always_comb begin
        read_data_buffer = 16'b0;
        if (!sram_ce_n && sram_we_n && !sram_oe_n) begin
            read_data_buffer = RAM[sram_addr];
        end
    end

    // Tri-state bus driver
    assign sram_data = (!sram_ce_n && sram_we_n && !sram_oe_n) ? read_data_buffer : 16'hzzzz;

endmodule
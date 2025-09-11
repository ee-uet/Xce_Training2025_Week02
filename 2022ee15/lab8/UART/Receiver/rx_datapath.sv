module rx_datapath #(
    parameter DATA_BITS = 8
)(
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   rx,
    input  logic                   data_sample_tick, 
    input  logic                   shift_en,         
    input  logic                   data_valid_fsm,   
    output logic [DATA_BITS-1:0]   data_out,
	output logic 				   parity_bit
);
    
    logic [DATA_BITS-1:0] shift_reg;
    logic [DATA_BITS-1:0] output_reg;
    
    // Shift register: capture bits during DATA state
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            shift_reg <= '0;
        end else if (shift_en && data_sample_tick) begin
            shift_reg <= {rx, shift_reg[DATA_BITS-1:1]};  // LSB-first capture
            
        end
    end
    
    // Output register: latch full data when FSM signals data_valid
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            output_reg <= '0;
           
        end 
		else if (data_valid_fsm) begin
           
                output_reg <= shift_reg;
				parity_bit <= rx;
		end
		else begin
			parity_bit <= 1'bx;
		end
         
    end

    assign data_out = output_reg;
    
endmodule

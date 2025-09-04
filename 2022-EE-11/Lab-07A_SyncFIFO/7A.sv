module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                    		clk,
    input  logic                    		rst_n,
    input  logic                    		wr_en,
    input  logic [DATA_WIDTH-1:0]   		wr_data,
    input  logic                    		rd_en,
    output logic [DATA_WIDTH-1:0]   		rd_data,
    output logic                    		full,
    output logic                    		empty,
    output logic                    		almost_full,
    output logic                    		almost_empty,
    output logic [$clog2(FIFO_DEPTH) : 0] 	count
);

    // TODO: Implement FIFO logic
    // Consider: How to generate flags without glitches?
    
    logic [DATA_WIDTH-1:0] fifo [FIFO_DEPTH];
    logic [$clog2(FIFO_DEPTH)-1 : 0] rd_ptr, wr_ptr;
    
    always_ff @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    	
    		wr_ptr		<= #1 0;
    		rd_ptr		<= #1 0;
    		count		<= #1 0;
    		rd_data		<= #1 0;
    		
    		for(int i = 0; i < FIFO_DEPTH; i++) begin
        		fifo[i] <= #1 'h0;  // Proper initialization
		end
		
    	end else begin
    		casez({wr_en, rd_en, full, empty})
    			4'b100?: begin
    				 fifo[wr_ptr]	<= #1 wr_data;
    				 wr_ptr		<= #1 (wr_ptr == FIFO_DEPTH - 1) ? 0 : wr_ptr + 1;
    				 count		<= #1 count + 1;
    				 end
			4'b01?0: begin
				 rd_data	<= #1 fifo[rd_ptr];
				 rd_ptr		<= #1 (rd_ptr == FIFO_DEPTH - 1) ? 0 : rd_ptr + 1;
				 count		<= #1 count - 1;
				 end
			4'b1100: begin
				 fifo[wr_ptr]	<= #1 wr_data;
				 rd_data	<= #1 fifo[rd_ptr];
				 rd_ptr		<= #1 (rd_ptr == FIFO_DEPTH - 1) ? 0 : rd_ptr + 1;
				 wr_ptr		<= #1 (wr_ptr == FIFO_DEPTH - 1) ? 0 : wr_ptr + 1;
				 end
    		endcase
    	end
    end

    assign almost_full 	= (count >= ALMOST_FULL_THRESH) ? 1 : 0;
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH) ? 1 : 0;
    
    assign full		= ((rd_ptr == wr_ptr) & almost_full) ? 1 : 0;
    assign empty	= ((rd_ptr == wr_ptr) & almost_empty) ? 1 : 0;
    
endmodule


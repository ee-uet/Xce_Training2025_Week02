module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2,
	parameter int PTR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
	output logic [$clog2(FIFO_DEPTH)-1:0] count
);

    // TODO: Implement FIFO logic
    
	
	logic [DATA_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
	logic [PTR_WIDTH:0] wr_ptr, rd_ptr;  
	
	always_ff @(posedge clk or negedge rst)
	begin
		if (!rst) begin
			rd_ptr <= 0;
			wr_ptr <= 0;
			count <= 4'b0;
		end
		else begin
			if (wr_en && !full && rd_en && !empty) begin
				wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1; 
                rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
			end	
		end
	end
	
	always_ff @(posedge clk) begin
        if (wr_en && !full) begin
				fifo[wr_ptr] <= wr_data;
				wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1; 
				count <= count + 4'b1;
        end
		if (rd_en && !empty) begin
				rd_data <= fifo[rd_ptr];
				rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
				count <= count - 4'b1;
		end
	end
	
	
	assign full = (count == FIFO_DEPTH) ? 1 : 0;
	assign empty = (count == 0) ? 1 : 0;
	assign almost_empty = (count <= ALMOST_EMPTY_THRESH) ? 1 : 0;
	assign almost_full = (count >= ALMOST_FULL_THRESH) ? 1 : 0;
		
endmodule

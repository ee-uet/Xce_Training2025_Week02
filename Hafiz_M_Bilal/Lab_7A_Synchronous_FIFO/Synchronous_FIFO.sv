module Synchronous_FIFO #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2,
    parameter int PTR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [$clog2(FIFO_DEPTH) - 1:0] count
);

    // TODO: Implement FIFO logic
   
    
    logic [DATA_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
    logic [PTR_WIDTH - 1:0] wr_ptr, rd_ptr;  // Extra bit for wrap-around detection
    
    always_ff @(posedge clk or negedge rst_n)
    begin
        if (!rst_n) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            count <= 4'b0;
        end
        else begin
            // Simultaneous read and write (most efficient case)
            if (wr_en && !full && rd_en && !empty) begin
                wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1; 
                rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
            end    
        else if(rd_en && !empty) begin
                rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
                count <= count - 1;
            end
        else if (wr_en && !full) begin
                wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1; 
                count <= count + 1;
            end
        
        end
    end
    
    // FIFO memory and data output register
    always_ff @(posedge clk) begin
        if (wr_en && !full) begin
            fifo[wr_ptr] <= wr_data;  // Write data to current write pointer position
        end
        if (rd_en && !empty) begin
            rd_data <= fifo[rd_ptr];  // Read data from current read pointer position
        end
    end
    
    // Status flags (combinational for immediate response)
    assign full = (count == FIFO_DEPTH-1) ? 1 : 0;
    assign empty = (count == 0) ? 1 : 0;
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH) ? 1 : 0;
    assign almost_full = (count >= ALMOST_FULL_THRESH) ? 1 : 0;
        
endmodule
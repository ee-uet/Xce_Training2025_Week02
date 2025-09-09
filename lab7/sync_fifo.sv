module sync_fifo #(
parameter int DATA_WIDTH = 8,
parameter int FIFO_DEPTH = 16,
parameter int ALMOST_FULL_THRESH = 14,
parameter int ALMOST_EMPTY_THRESH = 2
)(
input logic clk,
input logic rst_n,
input logic wr_en,
input logic [DATA_WIDTH-1:0] wr_data,
input logic rd_en,
output logic [DATA_WIDTH-1:0] rd_data,
output logic full,
output logic empty,
output logic almost_full,
output logic almost_empty,
output logic [$clog2(FIFO_DEPTH):0] count
);
logic [DATA_WIDTH-1:0]fifo[FIFO_DEPTH-1:0];
// TOD: Implement FIFO logic
logic [$clog2(FIFO_DEPTH)-1:0] rptr,rptr_n,wptr,wptr_n;
assign rptr_n=rptr+1;
assign wptr_n=wptr+1;
assign count=$unsinged(wptr-rptr);
always_ff @( negedge clk ) begin 
    if (!rst_n) begin
        wptr<=0;
    end else if (wr_en & !full) begin
        fifo[wptr]<=wr_data;
        wptr<=wptr_n;
    end
        
end

always_ff @( negedge clk ) begin 
    if (!rst_n) begin
        rptr<=0;
        rd_data<=0;
    end else if (rd_en & !empty) begin
        rd_data <= fifo[rptr];
        rptr<=rptr_n;
    end
        
end

// Consider: How to generate flags without glitches?
assign empty=(rptr==wptr);
assign full =((wptr+1)==rptr);
assign almost_empty=((wptr-rptr)==ALMOST_EMPTY_THRESH);
assign almost_full =((rptr+ALMOST_FULL_THRESH)==wptr);
endmodule
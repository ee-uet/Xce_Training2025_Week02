module fifo #(FIFO_DEPTH=8)(
    input logic clk,rst_n,
    input logic [7:0]rx_data,
    input logic rx_valid,
    input logic fifo_rd_en,
    output logic tx_ready,
    output logic tx_busy,
    output logic [7:0]tx_data
);
    logic [$clog2(FIFO_DEPTH)-1:0] wptr,wptr_n,rptr,rptr_n;
    logic [7:0]fifo[FIFO_DEPTH-1:0];
    always_comb begin 
            rptr_n=rptr+1;
            wptr_n=wptr+1;
    end

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            rptr<=0;
        end 
        if (fifo_rd_en && tx_busy) begin
            rptr<=rptr_n;
        end
    end

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            wptr<=0;
        end
        if (rx_valid && tx_ready) begin
            fifo[wptr]<=rx_data;
            wptr<=wptr_n;
        end
    end
assign tx_ready=(wptr+1 != rptr);
assign tx_busy=(rptr!=wptr);
assign tx_data=fifo[rptr];
endmodule
module fifo #(FIFO_DEPTH=8)(
    input logic clk,rst_n,
    input logic [7:0]Rx_Data,
    input logic Rx_Valid,
    input logic Tx_Ready,
    output logic Tx_Valid,
    output logic [7:0]Tx_Data
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
        if (Tx_Valid && Tx_Ready) begin
            rptr<=rptr_n;
        end
    end

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            wptr<=0;
        end
        if (Rx_Valid) begin
            fifo[wptr]<=Rx_Data;
            wptr<=wptr_n;
        end
    end
assign Tx_Valid=(rptr!=wptr);
assign Tx_Data=fifo[rptr];
endmodule
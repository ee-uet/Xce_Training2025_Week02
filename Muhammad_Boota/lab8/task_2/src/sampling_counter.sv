module sampling_counter #(
    parameter int COUNT_VALUE =8
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    output logic counted
);
logic [$clog2(COUNT_VALUE)-1:0]count,count_next;
logic counted_n;
    always_comb begin 
        counted_n=(count==(COUNT_VALUE/2)-1);
        count_next=(count==COUNT_VALUE-1) ? 0:count+1;
    end
    
    always_ff @( posedge clk ) begin : blockName
        if (!rst_n)begin
            count<=0;
            counted<=0;
        end else if(enable) begin
            count<=count_next;
            counted<=counted_n;
        end
    end
endmodule
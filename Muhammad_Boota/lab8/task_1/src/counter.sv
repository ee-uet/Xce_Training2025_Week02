module counter #(
    parameter int COUNT_VALUE =8
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    output logic counted
);
logic [$clog2(COUNT_VALUE):0]count,count_next;
logic counted_n;
    always_comb begin 
        counted_n=(count==COUNT_VALUE);
        if (enable)begin
            count_next=(count==COUNT_VALUE) ? 0:count+1;
        end else begin
            count_next=count;
        end
    end
    
    always_ff @( posedge clk ) begin : blockName
        if (!rst_n)begin
            count<=0;
            counted<=0;
        end else begin
            count<=count_next;
            counted<=counted_n;
        end
    end
endmodule
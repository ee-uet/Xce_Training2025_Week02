module counter #(
    COUNT_VALUE
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    output logic counted
);
logic [$cloge(COUNT_VALUE)-1:0]count,count_next;
logic counted_n;
    always_comb begin 
        counted_n=(count==COUNT_VALUE-1);
        if (enable)begin
            count_next=(count==COUNT_VALUE-1) ? 0;count+1;
        end else begin
            count_next=count;
        end
    end
    
    always_ff @( posedge clk ) begin : blockName
        if (!rst_n)
            count<=0;
            counted<=0;
        else
            count<=count_next;
            counted<=counted_n;
    end
endmodule
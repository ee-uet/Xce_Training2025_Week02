module programmable_counter (
input logic clk,
input logic rst_n,
input logic load,
input logic enable,
input logic up_down,
input logic [7:0] load_value,
input logic [7:0] max_count,
output logic [7:0] count,
output logic tc, // Terminal count
output logic zero
);
logic [7:0]count_n;
// TOD: Implement counter logic
always_ff @( posedge clk ) begin 
    if (!rst_n)
        count<=0;
    else 
        count<=count_n;
end
// Consider: What happens when max_count changes during operation?
always_comb begin 
    if (load && (tc || zero)) begin
        count_n=load_value;
    end else if(enable) begin
        if (up_down) begin
            count_n=(!tc) ? count+1:count;
        end else begin
            count_n=(!zero) ? count-1:count;
        end
    end else begin
        count_n=count;
    end
end

assign tc=(count==max_count);
assign zero=(count==8'b0);
endmodule
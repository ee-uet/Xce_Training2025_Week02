module prog_counter (
input  logic        clk,
input  logic        rst_n,
input  logic        load,
input  logic        enable,
input  logic        up_down,    // 0 --> down count, 1--> up count
input  logic [7:0]  load_value,
input  logic [7:0]  max_count,
output logic [7:0]  count,
output logic        tc,          
output logic        zero
);
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= 8'd0;
    else if (load)              // if load = 1, load the count value
        count <= load_value;
    else if (enable) begin      // if enable = 1, start count up or down
        if (up_down) begin
            if (count == max_count) begin
                count <= 8'd0;
            end 
            else begin
                count <= count + 1;
            end
        end 
        else begin
            if (count == 8'd0) begin
                count <= max_count;
            end 
            else begin
                count <= count - 1;
            end
        end 
    end
    else begin
        count <= count;
    end
end
assign tc = (count == max_count); // Output = 1 when count reaches max_count
assign zero = (count == 8'd0);    // Output = 1 when count reaches 0
endmodule
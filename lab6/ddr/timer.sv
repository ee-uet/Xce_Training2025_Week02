module timer (
    input logic clk,
    input logic rst_n,
    input logic count_start,
    input logic [4:0] count_value,
    output logic count_done

);
assign [4:0] count = count_value;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_done <= 1'b0;
    end else if (count_start) begin
        if (count == 5'd0) begin
            count_done <= 1'b1;
        end else begin
            count_done <= 1'b0;
            count <= count - 5'd1;
        end
    end else begin
        count_done <= 1b'0;
    end
end
endmodule
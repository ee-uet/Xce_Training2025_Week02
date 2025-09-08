module counter (
    input logic div_clk,
    input logic rst_n,
    input logic start_count,
    output logic count_done
);

logic [3:0] current_count;

always_ff @(posedge div_clk or negedge rst_n) begin
    if (!rst_n) begin
        current_count <= 4'd0;
        count_done <= 1'b0;
    end 
    else if (start_count) begin
        if (current_count == 4'd8) begin
            current_count <= 4'd0;
            count_done <= 1'b1;  // Pulse for one cycle
        end else begin
            current_count <= current_count + 1;
            count_done <= 1'b0;
        end
    end
    else begin
        current_count <= 4'd0;
        count_done <= 1'b0;
    end
end

endmodule

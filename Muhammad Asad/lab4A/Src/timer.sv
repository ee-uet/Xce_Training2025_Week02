module timer (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       count_start,
    input  logic [4:0] count_value,
    output logic       count_done
);

    logic [4:0] count;
    logic counting, counting2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 5'd0;
            count_done <= 1'b0;
            counting <= 1'b0;
            counting2 <= 1'b0;
        end else if (count_start && !counting) begin
            // Start new count sequence
            count <= count_value;
            count_done <= 1'b0;
            counting2 <= 1'b1;
            if (counting2) begin
                counting <= 1;
            end
        end else if (counting) begin
            if (count == 5'd0) begin
                count_done <= 1'b1;
                counting2 <= 1'b0;
                counting <= 1'b0;
            end else begin
                count <= count - 5'd1;
                count_done <= 1'b0;
            end
        end else begin
            count_done <= 1'b0;
        end
    end

endmodule
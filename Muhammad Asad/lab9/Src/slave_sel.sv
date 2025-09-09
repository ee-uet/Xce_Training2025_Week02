module save_sel (
    input logic [1:0] slave_sel,
    input logic start_count,
    output logic [3:0] slave_out
);
always_comb begin
    case (slave_sel)
        2'b00: begin
            if (start_count) begin
                slave_out =   4'b1110; // Select Slave 1
            end else begin
                slave_out = 4'b1111;   // No slave selected
            end
        end
        2'b01: begin
            if (start_count) begin
                slave_out =   4'b1101; // Select Slave 2
            end else begin
                slave_out = 4'b1111;   // No slave selected
            end
        end
        2'b10: begin
            if (start_count) begin
                slave_out =   4'b1011;  // Select Slave 3
            end else begin
                slave_out = 4'b1111;    // No slave selected
            end
        end
        2'b11: begin
            if (start_count) begin
                slave_out =   4'b0111;  // Select Slave 4
            end else begin
                slave_out = 4'b1111;    // No slave selected
            end
        end
        default: slave_out = 4'b1111;   // No slave selected
    endcase
end

endmodule
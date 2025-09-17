module Alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic signed [2:0] op_sel,
    output logic signed [7:0] result,
    output logic              zero, carry, overflow
);

    logic [8:0] tmp;

    always_comb begin
        result   = 0;
        carry    = 0;
        overflow = 0;
        zero     = 0;

        case (op_sel)
            3'b000: begin
                tmp      = a + b;
                result   = tmp[7:0];
                carry    = tmp[8];
                overflow = (a[7] == b[7]) && (result[7] != a[7]);
            end
            3'b001: begin
                tmp      = a - b;
                result   = tmp[7:0];
                carry    = tmp[8];
                overflow = (a[7] != b[7]) && (result[7] != a[7]);
            end
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ~a;
            3'b110: begin
                result = {a[6:0],1'b0};
                carry  = a[7];
            end
            3'b111: result = {1'b0,a[7:1]};
        endcase

        zero = (result == 0);
    end

endmodule

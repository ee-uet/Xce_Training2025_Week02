module alu_8bit (
    input  logic [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);

    // TODO: Implement operation selection
    assign [8:0]tmp_add = {1b'0,a} + {1'b0,b};
    assign [8:0]tmp_sub = {1b'0,a} + {1'b0,~b} + 9'd1;

    always_comb begin
        // Initialize all outputs
        result      = 8'b00000000;
        carry       = 1'b0;
        overflow    = 1'b0;
        
        case (op_sel)
            // TOO: Implement each operation
            3'b000: begin
                result      = tmp_add[7:0];
                carry       = tmp_add[8];
                overflow    = (a[7] == b[7]) && (result[7] != a[7]);
            end
            3'b001: begin
                result      = tmp_sub[7:0];
                carry       = tmp_sub[8];
                overflow    = (a[7] != b[7]) && (result[7] != a[7]);
            end
            3'b010: begin
                result      = a & b;
            end
            3'b011: begin
                result      = a | b;
            end
            3'b100: begin
                result      = a ^ b;
            end
            3'b101: begin
                result      = ~a;
            end
            3'b110: begin
                result      = {a[6:0],  1'b0};
                carry       = a[7];
            end
            3'b111: begin
                result      = {1'b0  ,a[7:1]}
                carry       = a[0];
            end            
            // Consider overflow detection logic
            default:begin
                result      = 8'b0;
            end
        endcase

                zero = (result == 8'b0);

    end

endmodule

module alu_8bit (
    input  logic [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);
    always_comb begin
        // Initialize all outputs
        carry = 1'b0;
        overflow = 1'b0;
        
        case (op_sel)
            0: begin // Addition
                {carry, result} = a + b;
                // Overflow: two positives give negative OR two negatives give positive
                overflow = (~a[7] & ~b[7] & result[7]) | (a[7] & b[7] & ~result[7]);
            end
            1: begin // Subtraction
                {carry, result} = a - b;
                // Overflow: positive - negative = negative OR negative - positive = positive
                overflow = (~a[7] & b[7] & result[7]) | (a[7] & ~b[7] & ~result[7]);
            end
            2: begin // AND
                result = a & b;
                // Logical operations don't produce overflow
            end
            3: begin // OR
                result = a | b;
            end
            4: begin // XOR
                result = a ^ b;
            end
            5: begin // NOT
                result = ~a;
            end
            6: begin // Left shift
                result = a << b[2:0]; // Only use lower 3 bits for shift amount
            end
            7: begin // Right shift
                result = a >> b[2:0]; // Only use lower 3 bits for shift amount
            end
            default: result = 8'b0;
        endcase
        
        // Zero flag: result is zero
        zero = (result == 8'b0);
    end
endmodule

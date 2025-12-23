module alu_8bit (
    input  logic [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);

    logic [8:0] temp_add;
    logic [8:0] temp_sub;    
    
    always_comb begin
        
        carry = 1'b0;
        overflow = 1'b0;
        result = 8'b0;
        temp_add = 9'b0;
        temp_sub = 9'b0;
        
        case (op_sel)
            3'b000: begin // ADD
                temp_add = {1'b0, a} + {1'b0, b};
                result = temp_add[7:0];
                carry = temp_add[8];
                // Overflow occurs if:
                // Adding two positives gives negative, or
                // Adding two negatives gives positive
                overflow = (a[7] == b[7]) && (result[7] != a[7]);
            end
            
            3'b001: begin // SUB
                temp_sub = {1'b0, a} - {1'b0, b};
                result = temp_sub[7:0];
                carry = temp_sub[8];
                // Overflow occurs if:
                // Positive minus negative gives negative, or
                // Negative minus positive gives positive
                overflow = (a[7] != b[7]) && (result[7] != a[7]);
            end
                
            3'b010: result = a & b;     // AND
            3'b011: result = a | b;     // OR
            3'b100: result = a ^ b;     // XOR
            3'b101: result = ~a;        // NOT
            3'b110: result = a << b[2:0];    // SLL
            3'b111: result = a >> b[2:0];    // SRL
            
            default: result = 8'b0;
        endcase
        
        zero = (result == 8'b0);
    end

endmodule
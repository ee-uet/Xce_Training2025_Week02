module alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic signed[2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);
    always_comb begin
        carry = 1'b0;
        overflow = 1'b0;
        
        case(op_sel)
            3'b000: result = a + b; // Addition
            3'b001: result = a - b; // Subtraction
            3'b010: result = a & b; // Bitwise AND
            3'b011: result = a | b; // Bitwise OR
            3'b100: result = a ^ b; // Bitwise XOR
            3'b101: result = ~a;    // Bitwise NOT  
            3'b110: result = a << 1; // Logical left shift
            3'b111: result = a >> 1; // Logical right shift
            default: result = 8'b0;
        endcase
    
        zero = (result == 8'b0);
        overflow = ((op_sel == 3'b000) && ((a[7] == b[7]) && (result[7] != a[7]))) || // Addition overflow
                   ((op_sel == 3'b001) && ((a[7] != b[7]) && (result[7] != a[7]))); // Subtraction overflow
        carry = (op_sel == 3'b000) && (result < a); // Carry out for addition eg 8'b01111111 + 8'b00000001 = 8'b00000000 with carry out
   end

endmodule

 

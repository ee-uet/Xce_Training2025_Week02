module alu(
    input logic [7:0] a, b,
    input logic [2:0] op_sel,
    output logic [7:0] out,
    output logic zero, carry, overflow
);
      // TODO: Implement ALU Unit 
    logic [8:0] temp;
    
    always_comb 
    begin
        // Default assignments
        out = 8'b0;
        zero = 1'b0;
        carry = 1'b0;
        overflow = 1'b0;
        
        case(op_sel) 
        3'b000 : begin // Addition
            temp = a + b;
            out = temp[7:0];
            zero = (out == 8'b0);
            carry = temp[8]; // Carry is the 9th bit of the addition result
            overflow = ((a[7] & b[7] & ~out[7]) | (~a[7] & ~b[7] & out[7])); // Overflow for 2's complement addition
            end  
        
        3'b001 : begin // Subtraction
            temp = a - b;
            out = temp[7:0];
            zero = (out == 8'b0);
            carry = ~temp[8]; // Borrow/Carry for subtraction
            overflow = ((a[7] & ~b[7] & ~out[7]) | (~a[7] & b[7] & out[7])); // Overflow for 2's complement subtraction
            end 
        
        3'b010 : begin // AND
            out = a & b;
            zero = (out == 8'b0);
            end
        
        3'b011 : begin // OR
            out = a | b;
            zero = (out == 8'b0);
            end
        
        3'b100 : begin // XOR
            out = a ^ b;
            zero = (out == 8'b0);
            end
        
        3'b101 : begin // NOT
            out = ~a;
            zero = (out == 8'b0);
            end
        
        3'b110 : begin // Left shift
            out = a << 1;
            zero = (out == 8'b0);
            carry = a[7]; // Carry is the MSB shifted out
            end
        
        3'b111 : begin // Right shift
            out = a >> 1;
            zero = (out == 8'b0);
            carry = a[0]; // Carry is the LSB shifted out
            end
        
        default: begin
            out = 8'b0;
            zero = 1'b1;
            end
        endcase
    end
    
endmodule
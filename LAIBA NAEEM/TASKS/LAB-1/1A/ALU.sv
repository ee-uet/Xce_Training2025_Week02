module alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic signed [2:0] op_sel,
    output logic signed [7:0] result,
    output logic       zero, carry, overflow
);
logic [8:0] temp;
    // TODO: Implement operation selection
    always_comb begin
  
        // Initialize all outputs
        carry = 1'b0;
        overflow = 1'b0;
        zero = 1'b0;
        
        case (op_sel)
            // TODO: Implement each operation
            // Consider overflow detection logic
            3'b000:  begin
                result = ~a;
            end
            3'b001:  begin
                temp = a + b;
                result = temp [7:0];
                carry = temp[8];
                overflow = (a[7] == b[7]) && (result[7] != a[7]);
            end     
            3'b010: begin
                temp = a - b;
                result = temp[7:0];
                carry = temp[8];
                overflow = (a[7] != b[7]) && (result[7] != a[7]);
            end
            3'b011: begin
                result = a & b;
            end
            3'b100: begin
                result = a | b;
            end
            3'b101: begin
                result = a ^ b;
            end
            3'b110:  begin
                result = a << b;
            end
            3'b111: begin
                result = a >> b;
            end
            default: begin
              result = 8'b0;
              carry = 1'b0;
              overflow = 1'b0;
              zero = 1'b0;
            end
        endcase
        
        // TODO: Implement flag generation
       if ( result == 8'b0 ) begin
              zero = 1;
        end
    end

endmodule

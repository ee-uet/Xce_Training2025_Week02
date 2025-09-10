module alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);
    logic signed [8:0] sum, sub;

    always_comb begin
        // Initialize all outputs
        carry = 1'b0;
        overflow = 1'b0;
        zero = 1'b0;
        
        case (op_sel)
          3'b000: begin
               sum = {1'b0,a} + {1'b0,b};
               result = sum[7:0];
               carry =  sum[8];
               if ( (a[7] == b[7]) && (a[7] != result[7]) ) begin
                  overflow = 1'b1;
               end   
          end 
          3'b001: result = a & b;
          3'b010: result = a | b;
          3'b011: result = a ^ b;
          3'b100: begin
              sub = {1'b0,a} - {1'b0,b};
              result = sub[7:0];
              carry  = sub[8]; // borrow 
              if ( (a[7] != b[7]) && (result[7] != a[7]) ) begin
                 overflow = 1'b1;
              end

          end 
          3'b101: result = ~a;
          3'b110: result = a << b;
          3'b111: result = a >> b;
          default: result = 8'b0;
        endcase
        
        // Flag generation
        if(result == 8'b0) begin
            zero = 1'b1;
        end
    end

endmodule

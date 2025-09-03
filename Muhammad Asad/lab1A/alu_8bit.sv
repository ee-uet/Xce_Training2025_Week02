module alu_8bit (
    input  logic [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);

    logic [8:0] tmp;

    always_comb begin
        
        carry =     1'b0;
        overflow =  1'b0;
        zero =      1'b0;
        result =    8'b0;

        case (op_sel)
            3'b000: begin 
                tmp =       a + b;
                result =    tmp[7:0];
                carry =     tmp[8]; 
                overflow =  (a[7] == b[7]) && (result[7] != a[7]);
            end
            3'b001: begin 
                tmp =    a - b;
                result = tmp[7:0];
                
            end
            3'b010: begin 
                result = a & b;
            end
            3'b011: begin 
                result = a | b;
            end
            3'b100: begin 
                result = a ^ b;
            end
            3'b101: begin 
                result = ~a;
            end
            3'b110: begin 
                result = {a[6:0],1'b0};
                carry =  a[7];
            end
            3'b111: begin 
                result = {1'b0, a[7:1]};
                carry =  a[0];
            end
        endcase

        
        zero = (result == 8'b0);
    end

endmodule

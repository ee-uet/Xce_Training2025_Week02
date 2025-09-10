module Priority_Encoder (
    input  logic [7:0]operand,
    input  logic enable,
    output logic [2:0]out,
    output logic valid
);
   always_comb begin 
        out   = 3'b000;
        valid = enable;   
        priority casez (operand)
            8'b1???????: begin out = 3'b000;end 
            8'b01??????: begin out = 3'b001;end 
            8'b001?????: begin out = 3'b010;end 
            8'b0001????: begin out = 3'b011;end 
            8'b00001???: begin out = 3'b100;end 
            8'b000001??: begin out = 3'b101;end 
            8'b0000001?: begin out = 3'b110;end 
            8'b00000001: begin out = 3'b111;end 
            default: begin out = 3'b000; valid = 1'b0; end 
        endcase
   end 
endmodule
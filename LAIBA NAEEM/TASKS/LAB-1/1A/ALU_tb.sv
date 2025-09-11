module alu_8bit_tb();

      logic signed [7:0] a, b;
      logic signed [2:0] op_sel;
      logic signed [7:0] result;
      logic zero, carry, overflow;


alu_8bit DUT(.*);
initial begin
 op_sel = 3'b001;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);
 #10;
op_sel = 3'b010;
 a = 8'b00001110;
 b = 8'b00001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);

 op_sel = 3'b011;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);

 op_sel = 3'b100;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);

 op_sel = 3'b101;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);

 op_sel = 3'b110;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);

 op_sel = 3'b111;
 a = 8'b10101010;
 b = 8'b01001100;
 #10;
 $display("result = %d zero = %b carry = %b overflow = %b",result,zero,carry,overflow);
end
endmodule
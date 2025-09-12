import pkg::*;
module alu_tb #(TEST=1000) ();
    logic [7:0] num1,num2;
    operation  op;
    logic [7:0] out;
    logic overflow,zero,carry;
    ALU alu(
        .*
    );


    initial begin
        for (int i = 0;i<TEST ;i++ ) begin
            op  = operation'($urandom_range(-128,128));
            num1=$random;
            num2=$random;
        #1; 
        $display("%b %s %b =%b ,overflow_flag=%d,zero_flag=%d,carry_flag=%d",num1,op,num2,out,overflow,zero,carry); 
        end
        $finish;
    end
endmodule
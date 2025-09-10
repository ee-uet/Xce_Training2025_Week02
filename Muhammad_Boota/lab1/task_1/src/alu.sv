import pkg::*;
module ALU (
    input logic [7:0] num1,num2,
    input operation  op,
    output logic [7:0] out,
    output logic overflow,zero,carry
);
    logic [8:0]temp_out;
    always_comb begin 
        case (op)
        ADD:temp_out=num1+num2;
        SUB:temp_out=num1-num2;
        AND:temp_out=num1&num2;
        OR :temp_out=num1|num2;
        XOR:temp_out=num1^num2;
        NOT:temp_out=~num1;
        SLL:temp_out=num1<<num2[2:0];
        SRL:temp_out=num1>>num2[2:0];
            default: temp_out=0;
        endcase
    end

    assign out      =temp_out[7:0];
    assign carry    =(  (op==ADD)||(op==SUB) ) ? temp_out[8]:0;
    assign overflow =(num1[7] & num2[7] & ~out[7])|(~num1[7] & ~num2[7] & out[7]);
    assign zero     =(out==8'b0);
    
endmodule
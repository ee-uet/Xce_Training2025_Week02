module bit_ALU(

    // input/output signals
    input logic [7:0] A,B,
    input logic [2:0] op_sel,
    output logic [7:0] y,
    output logic zero,overflow,carry
);


//Internal signals
logic c_out;//representing carry out in case of addition

always_comb begin

    zero=0;//zero flag
    overflow=0;//overflow flag
    carry=0;// carry flag
    y=0;//output is zero initially
    
    //Main logic in=mplimented here
    case(op_sel)
    3'b000:begin
        y=A&B;
    end
    3'b001:begin
        y=A|B;
    end
    3'b010:begin
        y=A^B;
    end
    3'b011:begin
        y=~A;
    end
    3'b100:begin
        {c_out,y}= A + B;
        carry=c_out;
        if((A[7]==B[7]) && (y[7]!=A[7])) begin
        overflow=1;
        end
    end

    3'b101:begin
        {c_out,y}= A - B;
        carry= ~(c_out);
        if((A[7]!=B[7]) && (y[7]!=A[7])) begin
        overflow=1;
        end
    end
    3'b110:begin
        y=A<<B[2:0];
    end
    3'b111:begin
        y=A>>B[2:0];
    end
    default:begin
        y=0;
    end
endcase
zero=(y==0); //Zero flag got high if output(y) is 0.
end
endmodule
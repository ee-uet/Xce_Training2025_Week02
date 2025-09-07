module priority_encoder (
    input logic enable,
    input logic [7:0] in,
    output logic [2:0] out,
    output logic valid
);

always_comb begin
    //initialization of outputs at the start cun circuit should be in known state.    
    out=3'b000;
    valid=1'b0;
   
    //main logic implimentation.
    if (enable) begin
    casez(in)
    8'b1xxxxxxx:begin
        out=3'b111;valid=1'b1;//7
    end
    8'b01xxxxxx:begin
        out=3'b110;valid=1'b1;//6
        end
    8'b001xxxxx:begin 
        out=3'b101;valid=1'b1;//5
    end
    8'b0001xxxx:begin
        out=3'b100;valid=1'b1;//4
    end
    8'b00001xxx:begin
        out=3'b011;valid=1'b1;//3
    end
    8'b000001xx:begin
        out=3'b010;valid=1'b1;//2
    end
    8'b0000001x:begin
        out=3'b001;valid=1'b1;//1
    end
    8'b00000001:begin
        out=3'b000;valid=1'b1;//0
    end
    8'b00000000:begin         //all inputs zero case handeled here
        out=3'bxxx;valid=1'b0;
    end
    endcase
end
end
endmodule
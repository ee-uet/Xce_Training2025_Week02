import pkg::*;
module binary_to_bcd (
input  logic [7:0]  binary_in,
output logic [11:0] bcd_out // 3 BCD digits: [11:8][7:4][3:0]
);
//TOD: Implement Double-Dabble algorithm
    bcd temp;
    always_comb begin
        temp.nible_1=4'b0;
        temp.nible_2=4'b0;
        temp.nible_3=4'b0;
        temp.binary_in=binary_in;
        for (int i = 0;i<8 ;i++ ) begin
            if (temp.nible_1>4) temp.nible_1=temp.nible_1+2'b11; else temp.nible_1=temp.nible_1;
            if (temp.nible_2>4) temp.nible_2=temp.nible_2+2'b11; else temp.nible_2=temp.nible_2;
            if (temp.nible_3>4) temp.nible_3=temp.nible_3+2'b11; else temp.nible_3=temp.nible_3;
            temp=temp <<1;
        end
    end
// Consider: Combinational loop approach vs generate loops
assign bcd_out={temp.nible_1,temp.nible_2,temp.nible_3};
endmodule
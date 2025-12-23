import pkg::*;
module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0] shift_amt,
    input  direction left_right, // 0=left, 1=right
    input  mode shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);
    always_comb begin
        data_out=0; 
        unique case (shift_rotate)
            SHIFT:begin
                unique case (left_right)
                    LEFT :data_out = data_in<<shift_amt;
                    RIGHT:data_out = data_in>>shift_amt;
                endcase
            end 
            ROTATE:begin
                unique case (left_right)
                    LEFT :data_out= (data_in<<shift_amt)| (data_in>>(31-shift_amt));
                    RIGHT:data_out= (data_in>>shift_amt)| (data_in<<(31-shift_amt));
                endcase
            end 
        endcase
    end
endmodule
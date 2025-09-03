
module barrel_shifter_tb;
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;
    logic        shift_rotate;
    logic [31:0] data_out;

    barrel_shifter dut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .left_right(left_right),
        .shift_rotate(shift_rotate),
        .data_out(data_out)
    );

    initial begin
        data_in = 32'h8000_0001; shift_amt = 5'b00001; left_right = 0; shift_rotate = 0; 
        #5;
        data_in = 32'h8000_0001; shift_amt = 5'b00001; left_right = 0; shift_rotate = 1;
        #5;
        data_in = 32'h0000_0003; shift_amt = 5'b00010; left_right = 1; shift_rotate = 0; 
        #5;
        data_in = 32'h1234_5678; shift_amt = 5'b00100; left_right = 1; shift_rotate = 1; 
        #5;
       

        $finish;
    end
endmodule

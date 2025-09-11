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
        data_in = 32'hA5A5_A5A5;
        shift_amt = 5'b00001;
        left_right = 1;
        shift_rotate = 1;
        #10;
        $display("Shift Left by 1: %h -> %h", data_in, data_out);
        $finish;
    end

endmodule

module tb_barrel_shifter;

    // Inputs
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;
    logic        shift_rotate;

    // Output
    logic [31:0] data_out;

    barrel_shifter uut (.*);

    // Test procedure
    initial begin
        data_in = 32'h12345678; // fixed input

        // Left Logical Shift
        left_right = 0;      // left
        shift_rotate = 0;    // logical
        shift_amt = 5;
        #5;
        $display("Left Logical Shift by 5: 0x%08h -> 0x%08h", data_in, data_out);

        shift_amt = 6;
        #5;
        $display("Left Logical Shift by 6: 0x%08h -> 0x%08h", data_in, data_out);

        // Right Logical Shift
        left_right = 1;      // right
        shift_rotate = 0;    // logical
        shift_amt = 5;
        #5;
        $display("Right Logical Shift by 5: 0x%08h -> 0x%08h", data_in, data_out);

        shift_amt = 6;
        #5;
        $display("Right Logical Shift by 6: 0x%08h -> 0x%08h", data_in, data_out);

        // Left Rotate
        left_right = 0;      // left
        shift_rotate = 1;    // rotate
        shift_amt = 5;
        #5;
        $display("Left Rotate by 5: 0x%08h -> 0x%08h", data_in, data_out);

        shift_amt = 6;
        #5;
        $display("Left Rotate by 6: 0x%08h -> 0x%08h", data_in, data_out);

        // Right Rotate
        left_right = 1;      // right
        shift_rotate = 1;    // rotate
        shift_amt = 5;
        #5;
        $display("Right Rotate by 5: 0x%08h -> 0x%08h", data_in, data_out);

        shift_amt = 6;
        #5;
        $display("Right Rotate by 6: 0x%08h -> 0x%08h", data_in, data_out);

        $stop;
    end

endmodule

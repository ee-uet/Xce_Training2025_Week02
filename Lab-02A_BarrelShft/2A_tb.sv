module tb_barrel_shifter();
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;
    logic        shift_rotate;
    logic [31:0] data_out;
    
    // Instantiate the barrel shifter
    barrel_shifter dut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .left_right(left_right),
        .shift_rotate(shift_rotate),
        .data_out(data_out)
    );
    
    initial begin
        // Initialize VCD dump
        $dumpfile("2A.vcd");
        $dumpvars(0, tb_barrel_shifter);
        
        // Test 1: Left shift
        left_right = 0; shift_rotate = 0;
        data_in = 32'h0000000F;
        shift_amt = 5'd4;
        #10;
        $display("Left Shift: data_in=%h, shift_amt=%d, data_out=%h", data_in, shift_amt, data_out);
        
        // Test 2: Right shift
        left_right = 1; shift_rotate = 0;
        data_in = 32'hF0000000;
        shift_amt = 5'd4;
        #10;
        $display("Right Shift: data_in=%h, shift_amt=%d, data_out=%h", data_in, shift_amt, data_out);
        
        // Test 3: Right rotate
        left_right = 1; shift_rotate = 1;
        data_in = 32'h0000000F;
        shift_amt = 5'd4;
        #10;
        $display("Right Rotate: data_in=%h, shift_amt=%d, data_out=%h", data_in, shift_amt, data_out);
        
        // Test 4: Left rotate
        left_right = 0; shift_rotate = 1;
        data_in = 32'hF0000000;
        shift_amt = 5'd4;
        #10;
        $display("Left Rotate: data_in=%h, shift_amt=%d, data_out=%h", data_in, shift_amt, data_out);
        
        // Test 5: Maximum shift
        left_right = 0; shift_rotate = 0;
        data_in = 32'h00000001;
        shift_amt = 5'd31;
        #10;
        $display("Max Shift: data_in=%h, shift_amt=%d, data_out=%h", data_in, shift_amt, data_out);
        
        // Finish simulation
        #10 $finish;
    end
endmodule

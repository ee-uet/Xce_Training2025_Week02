module barrel_shifter_tb;
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;  // 0=left, 1=right
    logic        shift_rotate; // 0=shift, 1=rotate
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
        // Initialize with a test value
        data_in = 32'hF0F0F0F0;
        
        $display("Initial data: %h", data_in);
        $display("==========================================");
        
        // Test 1: Left shift by 4
        $display("Test 1: Left shift by 4");
        shift_amt = 5'd4;
        left_right = 1'b0;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 2: Left rotate by 4
        $display("\nTest 2: Left rotate by 4");
        shift_amt = 5'd4;
        left_right = 1'b0;
        shift_rotate = 1'b1;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 3: Right shift by 4
        $display("\nTest 3: Right shift by 4");
        shift_amt = 5'd4;
        left_right = 1'b1;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 4: Right rotate by 4
        $display("\nTest 4: Right rotate by 4");
        shift_amt = 5'd4;
        left_right = 1'b1;
        shift_rotate = 1'b1;
        #10;
        $display("data_out = %h", data_out);
        
        $display("\n==========================================");
        
        // Test with different shift amounts
        data_in = 32'h0000000F;
        
        $display("\nNew test data: %h", data_in);
        $display("==========================================");
        
        // Test 5: Left shift by 8
        $display("Test 5: Left shift by 8");
        shift_amt = 5'd8;
        left_right = 1'b0;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 6: Left rotate by 8
        $display("\nTest 6: Left rotate by 8");
        shift_amt = 5'd8;
        left_right = 1'b0;
        shift_rotate = 1'b1;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 7: Right shift by 8
        $display("\nTest 7: Right shift by 8");
        shift_amt = 5'd8;
        left_right = 1'b1;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        // Test 8: Right rotate by 8
        $display("\nTest 8: Right rotate by 8");
        shift_amt = 5'd8;
        left_right = 1'b1;
        shift_rotate = 1'b1;
        #10;
        $display("data_out = %h", data_out);
        
        // Test edge case: shift by 0
        $display("\nTest 9: Shift by 0 (should be same as input)");
        shift_amt = 5'd0;
        left_right = 1'b0;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        // Test edge case: shift by 31 (maximum)
        $display("\nTest 10: Left shift by 31 (maximum)");
        shift_amt = 5'd31;
        left_right = 1'b0;
        shift_rotate = 1'b0;
        #10;
        $display("data_out = %h", data_out);
        
        $finish;
    end
    
endmodule
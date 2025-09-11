module barrel_shifter_tb;
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;   // 0=left, 1=right
    logic        shift_rotate; // 0=shift, 1=rotate
    logic [31:0] data_out;
    
    // Instantiate the barrel shifter
    barrel_shifter uut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .left_right(left_right),
        .shift_rotate(shift_rotate),
        .data_out(data_out)
    );
    
    // Test cases
    initial begin
        // Initialize
        data_in = 32'h00000000;
        shift_amt = 5'b00000;
        left_right = 1'b1; // right shift
        shift_rotate = 1'b0; // shift
        
        // Test 1: No shift (identity)
        #10;
        data_in = 32'hF0F0F0F0;
        shift_amt = 5'b00000;
        #10;
        $display("Test 1 - No shift: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 2: Right shift by 1
        #10;
        shift_amt = 5'b00001;
        #10;
        $display("Test 2 - Right shift by 1: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 3: Right shift by 16
        #10;
        shift_amt = 5'b10000;
        #10;
        $display("Test 3 - Right shift by 16: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 4: Right shift by 31 (max)
        #10;
        shift_amt = 5'b11111;
        #10;
        $display("Test 4 - Right shift by 31: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 5: Right rotate by 8
        #10;
        shift_rotate = 1'b1; // rotate
        shift_amt = 5'b01000;
        #10;
        $display("Test 5 - Right rotate by 8: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 6: Left shift by 4
        #10;
        left_right = 1'b0; // left shift
        shift_rotate = 1'b0; // shift
        shift_amt = 5'b00100;
        #10;
        $display("Test 6 - Left shift by 4: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 7: Left rotate by 12
        #10;
        shift_rotate = 1'b1; // rotate
        shift_amt = 5'b01100;
        #10;
        $display("Test 7 - Left rotate by 12: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 8: Edge case - all ones
        #10;
        data_in = 32'hFFFFFFFF;
        shift_amt = 5'b01010; // shift by 10
        left_right = 1'b1; // right
        shift_rotate = 1'b0; // shift
        #10;
        $display("Test 8 - All ones, right shift by 10: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 9: Edge case - alternating pattern
        #10;
        data_in = 32'hAAAAAAAA;
        shift_amt = 5'b00101; // shift by 5
        #10;
        $display("Test 9 - Alternating pattern, right shift by 5: data_in=%h, data_out=%h", data_in, data_out);
        
        // Test 10: Random test
        #10;
        data_in = $random;
        shift_amt = $random;
        left_right = $random;
        shift_rotate = $random;
        #10;
        $display("Test 10 - Random: data_in=%h, shift_amt=%d, left_right=%b, shift_rotate=%b, data_out=%h",
                 data_in, shift_amt, left_right, shift_rotate, data_out);
        
        // Finish simulation
        #10;
        $display("All tests completed!");
        $finish;
    end
    
    // Monitor to track changes
    initial begin
        $monitor("Time=%0t: data_in=%h, shift_amt=%d, dir=%s, mode=%s, data_out=%h",
                 $time, data_in, shift_amt,
                 left_right ? "right" : "left",
                 shift_rotate ? "rotate" : "shift",
                 data_out);
    end
    
    // Generate waveform file
    initial begin
        $dumpfile("barrel_shifter.vcd");
        $dumpvars(0, barrel_shifter_tb);
    end
    
endmodule 
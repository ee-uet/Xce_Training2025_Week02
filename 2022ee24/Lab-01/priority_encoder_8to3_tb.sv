module priority_encoder_8to3_tb;
    logic enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic valid;
    
    // Instantiate the priority encoder
    priority_encoder_8to3 dut (
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );
    
    initial begin
        // Test case 1: Enable = 0 (disabled)
        $display("Test 1: Enable = 0 (disabled)");
        enable = 1'b0;
        data_in = 8'b10000000;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 2: All zeros (no active input)
        $display("\nTest 2: All zeros");
        enable = 1'b1;
        data_in = 8'b00000000;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 3: Highest priority (bit 7)
        $display("\nTest 3: Bit 7 active");
        enable = 1'b1;
        data_in = 8'b11111111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 4: Bit 6 active
        $display("\nTest 4: Bit 6 active");
        enable = 1'b1;
        data_in = 8'b01111111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 5: Bit 5 active
        $display("\nTest 5: Bit 5 active");
        enable = 1'b1;
        data_in = 8'b00111111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 6: Bit 4 active
        $display("\nTest 6: Bit 4 active");
        enable = 1'b1;
        data_in = 8'b00011111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 7: Bit 3 active
        $display("\nTest 7: Bit 3 active");
        enable = 1'b1;
        data_in = 8'b00001111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 8: Bit 2 active
        $display("\nTest 8: Bit 2 active");
        enable = 1'b1;
        data_in = 8'b00000111;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 9: Bit 1 active
        $display("\nTest 9: Bit 1 active");
        enable = 1'b1;
        data_in = 8'b00000011;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 10: Bit 0 active (lowest priority)
        $display("\nTest 10: Bit 0 active");
        enable = 1'b1;
        data_in = 8'b00000001;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        // Test case 11: Multiple bits active (priority test)
        $display("\nTest 11: Multiple bits active (bit 5 and 2)");
        enable = 1'b1;
        data_in = 8'b00100100;
        #10;
        $display("data_in = %8b, encoded_out = %3b, valid = %b", data_in, encoded_out, valid);
        
        $finish;
    end
    
endmodule
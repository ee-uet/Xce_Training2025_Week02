module tb_priority_encoder_8to3();
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
        // Initialize VCD dump
        $dumpfile("1B.vcd");
        $dumpvars(0, tb_priority_encoder_8to3);
        
        // Test 1: Disabled encoder
        enable = 0;
        data_in = 8'b10000000;
        #10;
        $display("Disabled: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Test 2: No input asserted
        enable = 1;
        data_in = 8'b00000000;
        #10;
        $display("No input: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Test 3: Highest priority (bit 7)
        enable = 1;
        data_in = 8'b10000000;
        #10;
        $display("Bit7: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Test 4: Lower priority (bit 3)
        enable = 1;
        data_in = 8'b00001000;
        #10;
        $display("Bit3: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Test 5: Multiple bits set (should prioritize highest)
        enable = 1;
        data_in = 8'b00110000;
        #10;
        $display("Multiple: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Test 6: Lowest priority (bit 0)
        enable = 1;
        data_in = 8'b00000001;
        #10;
        $display("Bit0: data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        
        // Finish simulation
        #10 $finish;
    end
endmodule

module binary_to_bcd_tb;
    logic [7:0]  binary_in;
    logic [11:0] bcd_out;
    
    // Instantiate the binary to BCD converter
    binary_to_bcd dut (
        .binary_in(binary_in),
        .bcd_out(bcd_out)
    );
    
    initial begin
        // Test case 1: 0
        $display("Test 1: binary_in = 0");
        binary_in = 8'd55;
        #10;
        $display("BCD: %d%d%d (hex: %h)", bcd_out[11:8], bcd_out[7:4], bcd_out[3:0], bcd_out);
        
        // Test case 2: 127 (max 7-bit value)
        $display("\nTest 2: binary_in = 127");
        binary_in = 8'd127;
        #10;
        $display("BCD: %d%d%d (hex: %h)", bcd_out[11:8], bcd_out[7:4], bcd_out[3:0], bcd_out);
        
        // Test case 3: 169
        $display("\nTest 3: binary_in = 169");
        binary_in = 8'd169;
        #10;
        $display("BCD: %d%d%d (hex: %h)", bcd_out[11:8], bcd_out[7:4], bcd_out[3:0], bcd_out);

        // Test case 4: 255 (max 8-bit value)
        $display("\nTest 4: binary_in = 255");
        binary_in = 8'd255;
        #10;
        $display("BCD: %d%d%d (hex: %h)", bcd_out[11:8], bcd_out[7:4], bcd_out[3:0], bcd_out);
        
        $finish;
    end
    
endmodule
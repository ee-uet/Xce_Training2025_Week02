module tb_binary_to_bcd();
    logic [7:0]  binary_in;
    logic [11:0] bcd_out;
    
    // Instantiate the binary to BCD converter
    binary_to_bcd dut (
        .binary_in(binary_in),
        .bcd_out(bcd_out)
    );
    
    initial begin
        // Initialize VCD dump
        $dumpfile("2B.vcd");
        $dumpvars(0, tb_binary_to_bcd);
        
        // Test 1: Minimum value
        binary_in = 8'd0;
        #10;
        $display("Binary: %d -> BCD: %d%d%d", binary_in, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
        
        // Test 2: Simple value
        binary_in = 8'd42;
        #10;
        $display("Binary: %d -> BCD: %d%d%d", binary_in, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
        
        // Test 3: Two-digit value
        binary_in = 8'd99;
        #10;
        $display("Binary: %d -> BCD: %d%d%d", binary_in, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
        
        // Test 4: Three-digit value
        binary_in = 8'd123;
        #10;
        $display("Binary: %d -> BCD: %d%d%d", binary_in, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
        
        // Test 5: Maximum value
        binary_in = 8'd255;
        #10;
        $display("Binary: %d -> BCD: %d%d%d", binary_in, bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
        
        // Finish simulation
        #10 $finish;
    end
endmodule

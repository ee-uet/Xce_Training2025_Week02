`timescale 1ns / 1ps

module tb_alu;

    // Inputs
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] op_sel;
    
    // Outputs
    logic [7:0] out;
    logic zero;
    logic carry;
    logic overflow;
    
    alu uut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .out(out),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );
    
    initial begin
        
        a = 0;
        b = 0;
        op_sel = 0;
        
		#50;
        
       
        $display("Testing ADDITION (op_sel = 000)");
        a = 8'd50;
        b = 8'd30;
        op_sel = 3'b000;
        #10;
        $display("a = %d, b = %d, out = %d, zero = %b, carry = %b, overflow = %b", a, b, out, zero, carry, overflow);
        
        
        a = 8'd200;
        b = 8'd100;
        #10;
        $display("a = %d, b = %d, out = %d, zero = %b, carry = %b, overflow = %b", a, b, out, zero, carry, overflow);
        
    
        $display("Testing SUBTRACTION (op_sel = 001)");
        a = 8'd100;
        b = 8'd40;
        op_sel = 3'b001;
        #10;
        $display("a = %d, b = %d, out = %d, zero = %b, carry = %b, overflow = %b", a, b, out, zero, carry, overflow);
        
        a = 8'd50;
        b = 8'd100;
        #10;
        $display("a = %d, b = %d, out = %d, zero = %b, carry = %b, overflow = %b", a, b, out, zero, carry, overflow);
        
        
        $display("Testing AND (op_sel = 010)");
        a = 8'b10101010;
        b = 8'b11001100;
        op_sel = 3'b010;
        #10;
        $display("a = %b, b = %b, out = %b, zero = %b", a, b, out, zero);

        $display("Testing OR (op_sel = 011)");
        a = 8'b10101010;
        b = 8'b11001100;
        op_sel = 3'b011;
        #10;
        $display("a = %b, b = %b, out = %b, zero = %b", a, b, out, zero);
        
        $display("Testing XOR (op_sel = 100)");
        a = 8'b10101010;
        b = 8'b11001100;
        op_sel = 3'b100;
        #10;
        $display("a = %b, b = %b, out = %b, zero = %b", a, b, out, zero);
        
        $display("\n=== Testing NOT (op_sel = 101) ===");
        a = 8'b10101010;
        op_sel = 3'b101;
        #10;
        $display("a = %b, out = %b, zero = %b", a, out, zero);
        
        // Test Case 7: Left Shift (110)
        $display("\n=== Testing LEFT SHIFT (op_sel = 110) ===");
        a = 8'b10101010;
        op_sel = 3'b110;
        #10;
        $display("a = %b, out = %b, zero = %b, carry = %b", a, out, zero, carry);
        
        a = 8'b01010101;
        #10;
        $display("a = %b, out = %b, zero = %b, carry = %b", a, out, zero, carry);
        
        // Test Case 8: Right Shift (111)
        $display("\n=== Testing RIGHT SHIFT (op_sel = 111) ===");
        a = 8'b10101010;
        op_sel = 3'b111;
        #10;
        $display("a = %b, out = %b, zero = %b, carry = %b", a, out, zero, carry);
        
        a = 8'b01010101;
        #10;
        $display("a = %b, out = %b, zero = %b, carry = %b", a, out, zero, carry);
        
        // Test Case 9: Zero Flag
        $display("\n=== Testing ZERO FLAG ===");
        a = 8'd0;
        b = 8'd0;
        op_sel = 3'b000; // Addition
        #10;
        $display("a = %d, b = %d, out = %d, zero = %b", a, b, out, zero);
        
        // Test Case 10: Overflow
        $display("\n=== Testing OVERFLOW ===");
        a = 8'd127; // Max positive for 8-bit signed
        b = 8'd1;
        op_sel = 3'b000; // Addition
        #10;
        $display("a = %d, b = %d, out = %d, overflow = %b", a, b, out, overflow);
        
        a = 8'd128; // Max negative for 8-bit signed
        b = 8'd255;
        op_sel = 3'b001; // Subtraction
        #10;
        $display("a = %d, b = %d, out = %d, overflow = %b", a, b, out, overflow);
        
        $display("\n=== Test Complete ===");
        #100;
        $finish;
    end
    
endmodule
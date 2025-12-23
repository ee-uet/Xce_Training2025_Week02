module alu_8bit_tb;
    logic [7:0] a, b;
    logic [2:0] op_sel;
    logic [7:0] result;
    logic zero, carry, overflow;
    
    // Instantiate the ALU
    alu_8bit dut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );
    
    initial begin
        // Test ADD operation - normal case
        $display("Testing ADD - Normal case:");
        a = 8'd10;
        b = 8'd20;
        op_sel = 3'b000;
        #10;
        $display("a = %d, b = %d, result = %d, zero = %b, carry = %b, overflow = %b", 
                 a, b, result, zero, carry, overflow);
        
        // Test ADD operation - overflow case
        $display("\nTesting ADD - Overflow case:");
        a = 8'd127;  // Maximum positive value
        b = 8'd1;
        op_sel = 3'b000;
        #10;
        $display("a = %d, b = %d, result = %d, zero = %b, carry = %b, overflow = %b", 
                 a, b, result, zero, carry, overflow);
        
        // Test SUB operation - normal case
        $display("\nTesting SUB - Normal case:");
        a = 8'd30;
        b = 8'd15;
        op_sel = 3'b001;
        #10;
        $display("a = %d, b = %d, result = %d, zero = %b, carry = %b, overflow = %b", 
                 a, b, result, zero, carry, overflow);
        
        // Test SUB operation - overflow case
        $display("\nTesting SUB - Overflow case:");
        a = 8'b10000000;  // -128 (minimum negative value)
        b = 8'd1;
        op_sel = 3'b001;
        #10;
        $display("a = %d, b = %d, result = %d, zero = %b, carry = %b, overflow = %b", 
                 a, b, result, zero, carry, overflow);
        
        $finish;
    end
    
endmodule
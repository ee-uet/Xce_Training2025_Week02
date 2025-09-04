module tb_alu_8bit();
    // Inputs
    logic [7:0] a, b;
    logic [2:0] op_sel;
    // Outputs
    logic [7:0] result;
    logic zero, carry, overflow;
    
    // Clock generation
    logic clk;
    always #5 clk = ~clk;
    
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
        // Initialize VCD dump
        $dumpfile("1A.vcd");
        $dumpvars(0, tb_alu_8bit);
        
        // Initialize inputs
        clk = 0;
        a = 0;
        b = 0;
        op_sel = 0;
        
        // Wait a little then start tests
        #10;
        
        // Test Addition
        op_sel = 0; a = 8'h80; b = 8'h80; #10;
        $display("ADD: %h + %h = %h (Carry=%b, Overflow=%b, Zero=%b)", a, b, result, carry, overflow, zero);
        
        // Test Subtraction
        op_sel = 1; a = 8'h80; b = 8'h81; #10;
        $display("SUB: %h - %h = %h (Carry=%b, Overflow=%b, Zero=%b)", a, b, result, carry, overflow, zero);
        
        // Test AND
        op_sel = 2; a = 8'hFF; b = 8'h0F; #10;
        $display("AND: %h & %h = %h (Zero=%b)", a, b, result, zero);
        
        // Test OR
        op_sel = 3; a = 8'hF0; b = 8'h0F; #10;
        $display("OR: %h | %h = %h (Zero=%b)", a, b, result, zero);
        
        // Test XOR
        op_sel = 4; a = 8'hFF; b = 8'hFF; #10;
        $display("XOR: %h ^ %h = %h (Zero=%b)", a, b, result, zero);
        
        // Test NOT
        op_sel = 5; a = 8'hAA; #10;
        $display("NOT: ~%h = %h (Zero=%b)", a, result, zero);
        
        // Test Left Shift
        op_sel = 6; a = 8'h01; b = 8'h02; #10;
        $display("SHL: %h << %h = %h (Zero=%b)", a, b[2:0], result, zero);
        
        // Test Right Shift
        op_sel = 7; a = 8'h80; b = 8'h02; #10;
        $display("SHR: %h >> %h = %h (Zero=%b)", a, b[2:0], result, zero);
        
        // Finish simulation
        #10 $finish;
    end
endmodule

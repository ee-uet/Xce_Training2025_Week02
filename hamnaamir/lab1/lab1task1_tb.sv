`timescale 1ns/1ps

module tb_alu_8bit;

    // Inputs
    logic signed [7:0] a, b;
    logic [2:0] op_sel;

    // Outputs
    logic [7:0] result;
    logic zero, carry, overflow;

    // Instantiate the ALU
    alu_8bit uut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .zero(zero),
        .carry(carry),
        .overflow(overflow)
    );

    initial begin
        // Test addition
        a = 8'd50; b = 8'd30; op_sel = 3'b000; #10;
        $display("ADD: a=%0d, b=%0d => result=%0d, carry=%b, overflow=%b, zero=%b", 
                  a, b, result, carry, overflow, zero);

        // Test AND
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b001; #10;
        $display("AND: a=%b, b=%b => result=%b, zero=%b", a, b, result, zero);

        // Test OR
        op_sel = 3'b010; #10;
        $display("OR: a=%b, b=%b => result=%b, zero=%b", a, b, result, zero);

        // Test XOR
        op_sel = 3'b011; #10;
        $display("XOR: a=%b, b=%b => result=%b, zero=%b", a, b, result, zero);

        // Test SUB
        a = 8'd20; b = 8'd50; op_sel = 3'b100; #10;
        $display("SUB: a=%0d, b=%0d => result=%0d, carry=%b, overflow=%b, zero=%b",
                  a, b, result, carry, overflow, zero);

        // Test NOT
        a = 8'b10101010; op_sel = 3'b101; #10;
        $display("NOT: a=%b => result=%b, zero=%b", a, result, zero);

        // Test shift left
        a = 8'b00001111; b = 3; op_sel = 3'b110; #10;
        $display("SHL: a=%b << %0d => result=%b", a, b, result);

        // Test shift right
        a = 8'b11110000; b = 2; op_sel = 3'b111; #10;
        $display("SHR: a=%b >> %0d => result=%b", a, b, result);

        $finish;
    end

endmodule

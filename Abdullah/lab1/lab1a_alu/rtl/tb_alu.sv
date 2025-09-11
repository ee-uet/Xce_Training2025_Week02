`timescale 1ns / 1ps

module tb_alu;

    // Inputs to the ALU
    logic [7:0] operand1;
    logic [7:0] operand2;
    logic [2:0] op_sel;
    
    // Outputs from the ALU
    logic [7:0] data_out;
    logic       zero;
    logic       carry;
    logic       overflow;

    // Operation Codes for op_sel
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110; // Shift Left
    localparam OP_SHR = 3'b111; // Shift Right

    alu uut (
        .operand1 (operand1),
        .operand2 (operand2),
        .op_sel   (op_sel),
        .data_out (data_out),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow)
    );
        
    // Task to apply a test vector and display results
    task apply_and_check(
        input [7:0] in1,
        input [7:0] in2,
        input [2:0] op
    );
        operand1 = in1;
        operand2 = in2;
        op_sel   = op;
        #10; 
        $display("op1=%-10d op2=%-10d op=%3b | out=%-10d Z=%b C=%b V=%b", 
                 operand1, operand2, op_sel, data_out, zero, carry, overflow);
    endtask

    // Main test sequence
    initial begin


        $display("               Starting ALU Testbench Simulation               ");
        $display("===============================================================");
        operand1 = 0;
        operand2 = 0;
        op_sel   = 0;
        #50; 

        $display("\n--- Testing ADDITION ---");
        apply_and_check(8'd50,   8'd30,   OP_ADD);
        apply_and_check(8'd200,  8'd100,  OP_ADD); 
        apply_and_check(8'd127,  8'd1,    OP_ADD); 

        $display("\n--- Testing SUBTRACTION ---");
        apply_and_check(8'd100,  8'd40,   OP_SUB);
        apply_and_check(8'd50,   8'd100,  OP_SUB); // Tests borrow (carry out)
        apply_and_check(8'h80,   8'd1,    OP_SUB); // Tests signed overflow (-128 - 1)

        $display("\n--- Testing LOGICAL AND ---");
        apply_and_check(8'b10101010, 8'b11001100, OP_AND);
        
        $display("\n--- Testing LOGICAL OR ---");
        apply_and_check(8'b10101010, 8'b11001100, OP_OR);
        
        $display("\n--- Testing LOGICAL XOR ---");
        apply_and_check(8'b10101010, 8'b11001100, OP_XOR);
        
        $display("\n--- Testing LOGICAL NOT ---");
        apply_and_check(8'b10101010, 8'hx, OP_NOT);

        $display("\n--- Testing SHIFT LEFT ---");
        apply_and_check(8'b10101010, 8'hx, OP_SHL);
        apply_and_check(8'b01010101, 8'hx, OP_SHL);

        $display("\n--- Testing SHIFT RIGHT ---");
        apply_and_check(8'b10101010, 8'hx, OP_SHR);
        apply_and_check(8'b01010101, 8'hx, OP_SHR);

        $display("\n--- Testing ZERO Flag ---");
        apply_and_check(8'd42, 8'd42, OP_SUB); // 42 - 42 should result in 0
        

        $display("                         Test Complete                         ");
        $display("===============================================================");
        #100;
        $finish;
    end
endmodule
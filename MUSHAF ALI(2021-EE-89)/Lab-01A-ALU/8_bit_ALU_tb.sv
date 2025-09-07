`timescale 1ns/1ps

module tb_ALU;

    // Testbench signals
    logic [7:0] A, B;
    logic [2:0] op_sel;
    logic [7:0] y;
    logic zero, overflow, carry;

    // Instantiate DUT
    bit_ALU dut (
        .A(A),
        .B(B),
        .op_sel(op_sel),
        .y(y),
        .zero(zero),
        .overflow(overflow),
        .carry(carry)
    );

    // Task to apply one test vector
    task apply_test(input [7:0] a_in, b_in, input [2:0] op);
        begin
            A = a_in;
            B = b_in;
            op_sel = op;
            #5; // wait for evaluation
            $display("Time=%0t | A=%0d (0x%0h), B=%0d (0x%0h), op_sel=%b => Y=%0d (0x%0h), Zero=%b, Carry=%b, Overflow=%b",
                        $time, A, A, B, B, op_sel, y, y, zero, carry, overflow);
        end
    endtask

    // Stimulus
    initial begin
        $display("--------- 8-bit ALU Testbench ---------");

        // Logic ops
        apply_test(8'h0F, 8'hF0, 3'b000); // AND
        apply_test(8'h0F, 8'hF0, 3'b001); // OR
        apply_test(8'hAA, 8'h55, 3'b010); // XOR
        apply_test(8'hF0, 8'h00, 3'b011); // NOT A

        // Arithmetic ops
        apply_test(8'h7F, 8'h01, 3'b100); // ADD (overflow expected)
        apply_test(8'hFF, 8'h01, 3'b100); // ADD (carry expected)
        apply_test(8'h80, 8'h01, 3'b101); // SUB (overflow expected)
        apply_test(8'h05, 8'h05, 3'b101); // SUB (result zero expected)

        // Shifts
        apply_test(8'h01, 8'h02, 3'b110); // A << 2
        apply_test(8'h80, 8'h01, 3'b111); // A >> 1

        $display("--------- Test Completed ---------");
        $stop;
    end

endmodule

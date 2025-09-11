module ALU (
    input  logic [7:0] A,        // Operand A (8-bit input)
    input  logic [7:0] B,        // Operand B (8-bit input)
    input  logic [2:0] op_sel,   // Operation select (3-bit control)
    output logic [7:0] result,   // Result of the operation
    output logic       Z,        // Zero flag: 1 if result == 0
    output logic       C,        // Carry flag: 1 if carry/borrow occurs
    output logic       V         // Overflow flag: 1 if signed overflow occurs
);

    logic [8:0] sum;  // 9-bit to store addition/subtraction with carry

    always_comb begin
        // Default values (reset each cycle)
        sum    = 9'd0;
        result = 8'd0;
        C      = 1'b0;
        V      = 1'b0;

        // Select operation based on op_sel
        case(op_sel)
            3'b000: begin  // ADD
                sum    = {1'b0, A} + {1'b0, B}; // Extend to 9 bits for carry
                result = sum[7:0];              // Lower 8 bits as result
                C      = sum[8];                // Carry-out (9th bit)
                V      = sum[7] ^ sum[8];       // Signed overflow detection
            end

            3'b001: begin  // SUB
                sum    = {1'b0, A} - {1'b0, B}; // Extend to detect borrow
                result = sum[7:0];
                C      = sum[8];                // Borrow bit
                V      = sum[7] ^ sum[8];       // Signed overflow detection
            end

            3'b010: result = A & B;   // AND
            3'b011: result = A | B;   // OR
            3'b100: result = A ^ B;   // XOR
            3'b101: result = ~A;      // NOT (on A only)
            3'b110: result = A << B;  // SHIFT LEFT
            3'b111: result = A >> B;  // SHIFT RIGHT

            default: result = 8'd0;   // Default: No operation
        endcase

        // Zero flag: set if result is all zeros
        Z = (result == 8'd0) ? 1'b1 : 1'b0;
    end

endmodule


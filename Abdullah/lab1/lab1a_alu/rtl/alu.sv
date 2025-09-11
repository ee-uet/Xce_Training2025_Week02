module alu (
    input  logic [7:0] operand1,
    input  logic [7:0] operand2,
    input  logic [2:0] op_sel,
    output logic [7:0] data_out,
    output logic       zero,
    output logic       carry,
    output logic       overflow
);
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110; // shift left
    localparam OP_SHR = 3'b111; // shift right

    // temporary 9-bit wire for handling carry in arithmetic operations
    logic [8:0] temp_result;

    always_comb begin
        // default assignments to prevent latches
        data_out = 8'b0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (op_sel)
            OP_ADD: begin
                // addition: c = a + b
                temp_result = {1'b0, operand1} + {1'b0, operand2};
                data_out    = temp_result[7:0];
                carry       = temp_result[8]; // carry is the 9th bit
                // overflow occurs if signs of inputs are the same, but different from the output sign
                overflow    = (operand1[7] == operand2[7]) && (operand1[7] != data_out[7]);
            end

            OP_SUB: begin
                // subtraction: c = a - b
                temp_result = {1'b0, operand1} - {1'b0, operand2};
                data_out    = temp_result[7:0];
                carry       = ~temp_result[8]; // carry is an inverted borrow
                // overflow occurs if signs of inputs differ, and output sign matches operand2's sign
                overflow    = (operand1[7] != operand2[7]) && (operand2[7] == data_out[7]);
            end

            OP_AND: begin
                data_out = operand1 & operand2;
            end

            OP_OR: begin
                data_out = operand1 | operand2;
            end

            OP_XOR: begin
                data_out = operand1 ^ operand2;
            end

            OP_NOT: begin
                // operand2 is ignored for this operation
                data_out = ~operand1;
            end

            OP_SHL: begin
                // logical shift left
                data_out = operand1 << 1;
                carry    = operand1[7]; // carry is the msb that was shifted out
            end

            OP_SHR: begin
                // logical shift right
                data_out = operand1 >> 1;
                carry    = operand1[0]; // carry is the lsb that was shifted out
            end

            default: begin
                // default case for any unused op_sel values
                data_out = 8'b0;
                carry    = 1'b0;
                overflow = 1'b0;
            end
        endcase

        // zero flag calculation
        // the zero flag is true if the final output is all zeros
        // calculated once, after the case statement, to avoid repetition
        zero = (data_out == 8'b0);
    end

endmodule
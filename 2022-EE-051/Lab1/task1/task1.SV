module alu_8bit (
    input  logic signed [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic signed [7:0] result,
    output logic zero,
    output logic carry,
    output logic overflow
);

    logic signed [8:0] temp;
    // Implement operation selection
    always_comb begin
        // Initialize all outputs
        result   = 8'b0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (op_sel)
            // Implement each operation
            // Consider overflow detection logic
            3'b000: result = a & b;           // AND
            3'b001: result = a | b;           // OR

            3'b010: begin                     // ADD
                temp   = a + b;              // temporary variable
                result = temp[7:0];
                carry  = temp[8];         
                overflow = (a[7] == b[7]) && (result[7] != a[7]);
            end

            3'b011: result = a << b;         // SLL 

            3'b100: begin                     // SUB
                temp   = a - b;
                result = temp[7:0];
                carry  = temp[8];             
                overflow = (a[7] != b[7]) && (result[7] != a[7]);
            end

            3'b101: result = a ^ b;           // XOR
            3'b110: result = a >> b;         // SRL 
            3'b111: result = ~a;             // NOT

            default: result = 8'b0;
        endcase

        // Zero flag
        zero = (result == 8'd0);
    end

endmodule


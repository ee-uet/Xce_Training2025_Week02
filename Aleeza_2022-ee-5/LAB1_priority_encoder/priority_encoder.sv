module priority_encoder (
    input  logic [7:0] D,    // 8 input lines (D7 = MSB, highest priority)
    input  logic       EN,    // Enable input
    output logic [2:0] Y,    // 3-bit encoded output
    output logic       V      // Valid signal
);

    always_comb begin
        if (EN) begin
            casez(D)  // casez allows 'z' and 'x' as don't care
                8'b1???????: Y = 3'b111;  // D7 = 1
                8'b01??????: Y = 3'b110;  // D6 = 1
                8'b001?????: Y = 3'b101;  // D5 = 1
                8'b0001????: Y = 3'b100;  // D4 = 1
                8'b00001???: Y = 3'b011;  // D3 = 1
                8'b000001??: Y = 3'b010;  // D2 = 1
                8'b0000001?: Y = 3'b001;  // D1 = 1
                8'b00000001: Y = 3'b000;  // D0 = 1
                default:     Y = 3'bxxx;  // No input active
            endcase

            // Valid signal
            V = |D;  // Reduction OR: checks if any of the bit is 1
        end
        else begin
            Y = 3'bxxx;  // output undefined if not enabled
            V = 1'b0;
        end
    end

endmodule


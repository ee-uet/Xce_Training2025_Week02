module tb_alu_8bit;
    logic signed [7:0] a, b;
    logic [2:0] op_sel;
    logic signed [7:0] result;
    logic zero, carry, overflow;

    alu_8bit DUT (.*);

    initial begin
        $display("op_sel | a | b | result | zero | carry | overflow");

        // AND
        a = 8'h0F; b = 8'hF0; op_sel = 3'b000; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // OR
        a = 8'h0F; b = 8'hF0; op_sel = 3'b001; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // ADD with overflow
        a = 8'd127; b = 8'd1; op_sel = 3'b010; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // SUB with borrow
        a = 8'd10; b = 8'd20; op_sel = 3'b100; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // Shift left
        a = 8'b1001_0001; b = 8'd1; op_sel = 3'b011; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // Shift right
        a = 8'b1001_0001; b = 8'd1; op_sel = 3'b110; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // NOT
        a = 8'hFF; b = 8'd0; op_sel = 3'b111; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        // XOR
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b101; #10;
        $display("%b | %0d | %0d | %0d | %b | %b | %b",
                 op_sel, a, b, result, zero, carry, overflow);

        $finish;
    end
endmodule

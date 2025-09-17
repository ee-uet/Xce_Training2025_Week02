module Alu_8bit_tb;

    logic [7:0] a, b;
    logic [2:0] op_sel;
    logic [7:0] result;
    logic       zero, carry, overflow;

    Alu_8bit uut (
        .a          (a),
        .b          (b),
        .op_sel     (op_sel),
        .result     (result),
        .zero       (zero),
        .carry      (carry),
        .overflow   (overflow)
    );

    initial begin
        a = 0;     b = 0;     op_sel = 3'b000; #5
        a = 15;    b = 50;    op_sel = 3'b000; #10
        a = 8'h9A; b = 8'h32; op_sel = 3'b001; #10
        a = 8'hFE; b = 8'h0F; op_sel = 3'b010; #10
        a = 8'hFF; b = 8'h0F; op_sel = 3'b011; #10
        a = 8'hAB; b = 8'h55; op_sel = 3'b100; #10
        a = 8'h0F; b = 0;     op_sel = 3'b101; #10
        a = 8'h81; b = 0;     op_sel = 3'b110; #10
        a = 8'h82; b = 0;     op_sel = 3'b111; #10
        $finish;
    end

endmodule

module alu_8bit_tb;

    logic [7:0] a, b;
    logic [2:0] op_sel;
    logic [7:0] result;
    logic zero, carry, overflow;

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
        // Testing zero flag
        a = 8'd0; b = 8'd0; op_sel = 3'b000;
        #5 
        // Testing ADD a = 100, b = 50
        a = 8'd100; b = 8'd50; op_sel = 3'b000;
        #10;
        // Testing SUB  a = -100, b = 50
        a = 8'h9C; b = 8'h32; op_sel = 3'b001;
        #10;
       // Testing AND
        a = 8'hFF; b = 8'h0F; op_sel = 3'b010;
        #10;
        // Testing OR
        a = 8'hF0; b = 8'h0F; op_sel = 3'b011;
        #10;
        // Testing XOR
        a = 8'hAA; b = 8'h55; op_sel = 3'b100;
        #10;
        // Testing NOT
        a = 8'h0F; b = 8'h00; op_sel = 3'b101;
        #10;
        // Testing Shift Left
        a = 8'h81; b = 8'h00; op_sel = 3'b110;
        #10;
        // Testing Shift Right
        a = 8'h81; b = 8'h00; op_sel = 3'b111;
        #10;


        $finish;
    end

endmodule
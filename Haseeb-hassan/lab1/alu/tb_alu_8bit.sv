module tb_alu_8bit;

  logic clk, rst_n;
  logic [7:0] a, b;
  logic [2:0] op_sel;
  logic [7:0] result;
  logic zero, carry, overflow;

  // DUT instance
  alu_8bit dut (
    .a(a), .b(b),
    .op_sel(op_sel),
    .result(result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset
  initial begin
    rst_n = 0;
    #12 rst_n = 1;
  end

  // Stimulus
  initial begin
    a = 8'd10; b = 8'd5; op_sel = 3'b000; #10; // addition
    a = 8'd15; b = 8'd20; op_sel = 3'b001; #10; // subtraction
    a = 8'hF0; b = 8'h0F; op_sel = 3'b010; #10; // AND
    a = 8'hF0; b = 8'h0F; op_sel = 3'b011; #10; // OR
    a = 8'hAA; b = 8'h55; op_sel = 3'b100; #10; // XOR
    a = 8'h5A; b = 8'h00; op_sel = 3'b101; #10; // NOT
    a = 8'h81; b = 8'h00; op_sel = 3'b110; #10; // shift left
    a = 8'h81; b = 8'h00; op_sel = 3'b111; #10; // shift right

    $stop;
  end

endmodule

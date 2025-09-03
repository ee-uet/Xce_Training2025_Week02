`timescale 1ns/1ps

module tb_barrel_shifter;

  logic [31:0] a;
  logic [4:0]  shift_amt;
  logic        left_right;
  logic        shift_rotate;
  logic [31:0] y;

  // DUT
  barrel_shifter dut (
    .a(a),
    .shift_amt(shift_amt),
    .left_right(left_right),
    .shift_rotate(shift_rotate),
    .y(y)
  );

  // stimulus
  initial begin
    // case 1: left shift by 1
    a = 32'hA5A5_A5A5; shift_amt = 5'd1; left_right = 0; shift_rotate = 0;
    #10;

    // case 2: right shift by 4
    a = 32'h1234_ABCD; shift_amt = 5'd4; left_right = 1; shift_rotate = 0;
    #10;

    // case 3: left rotate by 8
    a = 32'hDEAD_BEEF; shift_amt = 5'd8; left_right = 0; shift_rotate = 1;
    #10;

    // case 4: right rotate by 16
    a = 32'hCAFEBABE; shift_amt = 5'd16; left_right = 1; shift_rotate = 1;
    #10;

    $finish;
  end

endmodule

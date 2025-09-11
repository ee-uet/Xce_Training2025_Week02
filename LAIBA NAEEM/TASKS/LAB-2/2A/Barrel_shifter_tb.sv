module barrel_shifter_tb();

  logic [31:0] data_in;
  logic [4:0]  shift_amt;
  logic        left_right;    // 0=left, 1=right
  logic        shift_rotate;  // 0=shift, 1=rotate
  logic [31:0] data_out;

  // Instantiate the barrel shifter
  barrel_shifter uut (
    .data_in(data_in),
    .shift_amt(shift_amt),
    .left_right(left_right),
    .shift_rotate(shift_rotate),
    .data_out(data_out)
  );

  initial begin
    // Left shift
    data_in = 32'h0000_000F;
    shift_amt = 5'b11111;  // shift by 3
    left_right = 0;
    shift_rotate = 0;
    #1; // wait for combinational update
    $display("Left shift : data_out = %h", data_out);

    // Left rotate
    shift_rotate = 1;
    #1;
    $display("Left rotate : data_out = %h", data_out);

    // Right shift
    left_right = 1;
    shift_rotate = 0;
    #1;
    $display("Right shift : data_out = %h", data_out);

    // Right rotate
    shift_rotate = 1;
    #1;
    $display("Right rotate : data_out = %h", data_out);
  end
endmodule

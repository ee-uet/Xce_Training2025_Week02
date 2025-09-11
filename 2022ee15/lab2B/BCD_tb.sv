`timescale 1ns/1ps

module tb_lab2b;

  // Testbench signals
  logic [7:0] in_bits;
  logic [11:0] bcd_bits;

  // Instantiate DUT
  lab2b dut (
    .in_bits(in_bits),
    .bcd_bits(bcd_bits)
  );

  // Task to display results
  task display_result(input [7:0] bin, input [11:0] bcd);
    $display("Time=%0t | Binary=%0d (%b) -> BCD=%0d%d%d",
              $time, bin, bin,
              bcd[11:8], bcd[7:4], bcd[3:0]);
  endtask

  initial begin
    // Apply test cases
    in_bits = 8'd0;   #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd5;   #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd9;   #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd12;  #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd37;  #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd99;  #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd123; #10; display_result(in_bits, bcd_bits);
    in_bits = 8'd255; #10; display_result(in_bits, bcd_bits);

    $finish;
  end

endmodule

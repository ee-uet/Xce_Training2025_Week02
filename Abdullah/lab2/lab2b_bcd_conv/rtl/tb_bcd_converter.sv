`timescale 1ns/1ps

module tb_cd_converter;

    // testbench signals
    logic [7:0] input_bits;
    logic [11:0] bcd_bits;


    bcd_converter dut (
        .input_bits(input_bits),
        .bcd_bits(bcd_bits)
    );

    // task to display results
    task display_result(input [7:0] bin, input [11:0] bcd);
        $display("Time=%0t | Binary=%0d (%b) -> BCD=%0d%d%d",
                 $time, bin, bin,
                 bcd[11:8], bcd[7:4], bcd[3:0]);
    endtask

    // test sequence
    initial begin
        // test case: binary 0
        input_bits = 8'd0;   #10; display_result(input_bits, bcd_bits);
        // (single digit)
        input_bits = 8'd5;   #10; display_result(input_bits, bcd_bits);
        // max single bcd digit
        input_bits = 8'd9;   #10; display_result(input_bits, bcd_bits);
        // two-digit number
        input_bits = 8'd12;  #10; display_result(input_bits, bcd_bits);
        // mid-range two-digit number
        input_bits = 8'd37;  #10; display_result(input_bits, bcd_bits);
        // high two-digit number
        input_bits = 8'd99;  #10; display_result(input_bits, bcd_bits);
        // three-digit number
        input_bits = 8'd123; #10; display_result(input_bits, bcd_bits);
        // max 8-bit input
        input_bits = 8'd255; #10; display_result(input_bits, bcd_bits);

        $finish;
    end

endmodule
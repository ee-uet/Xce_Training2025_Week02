`timescale 1ns/1ps
module tb_priority_encoder_8to3;

    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;

    // DUT
    priority_encoder_8to3 dut (
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );

    initial begin
        // start disabled
        enable   = 0; data_in = 8'b00000000; #10;

        // enable, test with one hot
        enable   = 1; data_in = 8'b00000001; #10;
        data_in = 8'b00000100; #10;
        data_in = 8'b00100000; #10;
        data_in = 8'b10000000; #10;

        // multiple bits set
        data_in = 8'b10101010; #10;

        // disable again
        enable = 0; data_in = 8'b11111111; #10;

        $finish;
    end

endmodule

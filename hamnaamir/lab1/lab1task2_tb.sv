module priority_encoder_8to3_tb;
    logic enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic valid;  // semicolon added

    // Instantiate DUT
    priority_encoder_8to3 dut (
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );

    initial begin
        enable = 1'b1;
        data_in = 8'b01010000; // concrete value

        #1;
        $display("data_in=%b, encoded_out=%b, valid=%b", data_in, encoded_out, valid);
        $finish;
    end
endmodule

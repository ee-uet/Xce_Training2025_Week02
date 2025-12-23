module priority_encoder_8to3_tb;
    logic enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic valid;

    priority_encoder_8to3 dut(
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );

    initial begin
        // Testing Active low disable (enable = 0)
        enable = 0; data_in = 8'b10101010; 
        #10;
        // Testing one 1 in input
        enable = 1; data_in = 8'b00010000; 
        #10; 
        // Testing with multiple 1's
        enable = 1; data_in = 8'b01011000; 
        #10; 
        // Testing with all zeros
        enable = 1; data_in = 8'b00000000; 
        #10;
        

        $finish;
    end
endmodule

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
        
        enable = 0; data_in = 8'b10101010; 
        #5;
        enable = 1; data_in = 8'b00010000; 
        #5; 
        enable = 1; data_in = 8'b01011000; 
        #5; 
        enable = 1; data_in = 8'b00000000; 
        #5;
        

        $finish;
    end
endmodule

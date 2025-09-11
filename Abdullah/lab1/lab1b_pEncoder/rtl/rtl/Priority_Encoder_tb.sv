`timescale 1ns/1ps

module Priority_Encoder_tb;

    // Testbench Internal signals
    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;

    // Instantiate DUT
    Priority_Encoder dut (
        .enable(enable),
        .data_in(data_in),
        .encoded_out(encoded_out),
        .valid(valid)
    );

    // Test sequence
    initial begin
		enable   = 0; 
		data_in = 8'b00000000; 
		#10;
		
		// test disabled state with multiple non-zero inputs
        enable   = 0; 
		data_in = 8'b10000000; 
		#10;
        enable   = 1; 
		data_in = 8'b10000000; 
		#10;
        data_in = 8'b01010101; 
		#10;
		data_in = 8'b00000101; 
		#10;
		data_in = 8'b00110000; 
		#10;
		data_in = 8'b00000001; 
		#10;
		data_in = 8'b00000000; 
        $finish;
    end

endmodule

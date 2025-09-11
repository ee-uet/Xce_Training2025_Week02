module priority_encoder_8to3_tb ();
     
logic       enable;
logic [7:0] data_in;
logic [2:0] encoded_out;
logic       valid;

priority_encoder_8to3 DUT(.*);

initial begin
enable = 1;
data_in = 8'b00000001;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
 #10;
data_in = 8'b00000010;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00000011;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00000100;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00000101;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00000110;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00000111;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b00010010;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b01000010;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b10000010;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
#10;
data_in = 8'b11111110;
 #10;
 $display("encoded_out = %b valid = %b",encoded_out,valid);
enable = 0;
end
endmodule

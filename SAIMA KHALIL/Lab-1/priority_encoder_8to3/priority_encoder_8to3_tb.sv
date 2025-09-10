
module priority_encoder_8to3_tb;
    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;
    
    priority_encoder_8to3 dut (.*);
  
    initial begin

        enable = 0; 
        data_in = 8'b010101;#5;
 
        enable = 1; 
        data_in = 8'b10000000;#5;

        data_in = 8'b10100000; #5;

        data_in = 8'b01000000;#5;
 
        data_in = 8'b00001000;#5;

        data_in = 8'b00000001; #5;
 
        data_in = 8'b00000000; #5;

      
        $finish;
    end

endmodule
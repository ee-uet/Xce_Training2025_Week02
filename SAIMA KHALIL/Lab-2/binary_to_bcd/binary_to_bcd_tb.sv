module binary_to_bcd_tb;
    logic [7:0] binary_in;
    logic [11:0] bcd_out;
    
    binary_to_bcd uut (.*);
    
    initial begin
        binary_in = 8'd0;
        #10;
        
        binary_in = 8'd5;
        #10;
     
        binary_in = 8'd10;
        #10;
       
        binary_in = 8'd99;
        #10;
     
        binary_in = 8'd127;
        #10;
      
        binary_in = 8'd255;
        #10;
    
        // Edge cases
        for (int i = 0; i < 10; i++) begin
            binary_in = $random;
            #10;
        end
        
        $finish;
    end
endmodule
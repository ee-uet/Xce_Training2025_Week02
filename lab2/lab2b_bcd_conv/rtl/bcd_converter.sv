module bcd_converter(
    input logic [7:0] input_bits,
    output logic [11:0] bcd_bits
    );
    logic [19:0] temp;     
    int i;
      
    // implemented using double dabble algorithm
always_comb 
    begin 
        temp = 20'b0;
        temp[7:0] = input_bits;  // load input into lower 8 bits of temp
		
        // 12-bit msb will hold the bcd output after processing
    
        for (i = 0; i < 8; i++)
        begin
            // add 3 to any bcd digit if >= 5 to ensure valid bcd in each section of temp register
            if(temp[11:8] >= 5)
            begin
                temp[11:8] = temp[11:8] + 4'b0011;
            end
        
            if(temp[15:12] >= 5)
            begin
                temp[15:12] = temp[15:12] + 4'b0011;
            end
        
            if(temp[19:16] >= 5)
            begin
                temp[19:16] = temp[19:16] + 4'b0011;
            end
        
            temp = temp << 1;  // shift left to process next bit
        end
    
        bcd_bits = temp[19:8];  // extract three 4-bit bcd digits
    end
endmodule
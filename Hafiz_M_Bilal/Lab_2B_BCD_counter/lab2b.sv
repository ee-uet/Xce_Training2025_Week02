module lab2b(
    input logic [7:0] in_bits,
    output logic [11:0] bcd_bits
    );
    logic [19:0] temp;
    int i;
      // TODO: Implement BCD Converter using Double Dable Algorithm 
always_comb 
begin 
    temp = 20'b0;
    temp[7:0] = in_bits;  // Load input into lower 8 bits
    
    for (i = 0;i<8;i++)
    begin
        // Add 3 to any BCD digit >= 5 (binary-to-BCD correction)
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
        
        temp = temp << 1;  // Shift left for next bit processing
    end
    
    bcd_bits = temp[19:8];  // Extract 3 BCD digits (12 bits)
    
end
endmodule
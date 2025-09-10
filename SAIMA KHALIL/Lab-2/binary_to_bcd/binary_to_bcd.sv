module binary_to_bcd (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out    // 3 BCD digits: [11:8][7:4][3:0]
  

);
    logic [19:0] shift_reg; // 8-bit binary + 12-bit BCD = 20 bits
     //[19:16] for Hundreds digit (BCD)
    //[15:12] for Tens digit (BCD)
    //[11:8]  for Units digit (BCD)
    //[7:0]   for original binary input ha ye
     
    always_comb begin
        // Initialize shift register with binary input and zeros for BCD
        shift_reg = {8'b0, binary_in};
        //  DoubleDabble algorithm for 8 iterations :D 
        for (int i = 0; i < 8; i++) begin //Each iteration shifts left by 1 and adjusts BCD digits if needed
            // Check each BCD digit and add 3 if ≥5
            // Hundreds digit (bits 19:16)
            if (shift_reg[19:16] >= 5) 
                shift_reg[19:16] = shift_reg[19:16] + 3;
            
            // Tens digit (bits 15:12)
            if (shift_reg[15:12] >= 5) 
                shift_reg[15:12] = shift_reg[15:12] + 3;
            
            // Units digit (bits 11:8)
            if (shift_reg[11:8] >= 5) 
                shift_reg[11:8] = shift_reg[11:8] + 3;
            
            // do left shift i-e whole shiftreg<<1 
            shift_reg = shift_reg << 1;
        end
        
        // Extract the BCD output (hundreds, tens, units)
        bcd_out = shift_reg[19:8];
    end

endmodule

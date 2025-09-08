module binary_to_bcd(
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out    
);

    logic [7:0]  shift_reg;   
    logic [11:0] bcd;         
    logic [19:0] combined;    

    always_comb begin
        
        shift_reg = binary_in;
        bcd       = 12'd0;

        
        for (int i = 0; i < 8; i++) begin
            
            if (bcd[11:8] >= 5)
                bcd[11:8] = bcd[11:8] + 3;
            if (bcd[7:4] >= 5)
                bcd[7:4] = bcd[7:4] + 3;
            if (bcd[3:0] >= 5)
                bcd[3:0] = bcd[3:0] + 3;

            
            combined   = {bcd, shift_reg};   
            combined   = combined << 1;      
            bcd        = combined[19:8];     
            shift_reg  = combined[7:0];      
        end

        
        bcd_out = bcd;
    end

endmodule

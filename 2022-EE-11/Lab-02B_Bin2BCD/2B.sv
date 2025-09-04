module binary_to_bcd (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out
);
    always_comb begin
        logic [19:0] temp;  // Wide enough for shifting
        temp = {12'b0, binary_in};
        
        // Process each bit
        for (int i = 0; i < 8; i++) begin
            // Add 3 to any digit > 4
            if (temp[19:16] > 4) temp[19:16] += 3;
            if (temp[15:12] > 4)  temp[15:12] += 3;
            if (temp[11:8] > 4)  temp[11:8] += 3;
            
            // Shift left
            temp = temp << 1;
        end
        
        bcd_out = temp[19:8];
    end
endmodule

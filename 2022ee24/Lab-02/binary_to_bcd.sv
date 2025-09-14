
module binary_to_bcd (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out    // 3 BCD digits: [11:8][7:4][3:0]
);

    logic [19:0] stage [0:8];
    
    // Initialize first stage
    assign stage[0] = {12'b0, binary_in};
    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : double_dabble
            logic [19:0] adjusted;
            
            // Adjustment phase (add 3 if digit >= 5)
            assign adjusted[19:16] = (stage[i][19:16] >= 5) ? stage[i][19:16] + 3 : stage[i][19:16];
            assign adjusted[15:12] = (stage[i][15:12] >= 5) ? stage[i][15:12] + 3 : stage[i][15:12];
            assign adjusted[11:8]  = (stage[i][11:8] >= 5)  ? stage[i][11:8] + 3  : stage[i][11:8];
            assign adjusted[7:0]   = stage[i][7:0];
            
            // Shift phase (left shift by 1)
            assign stage[i+1] = adjusted << 1;
        end
    endgenerate
    
    assign bcd_out = stage[8][19:8];

endmodule

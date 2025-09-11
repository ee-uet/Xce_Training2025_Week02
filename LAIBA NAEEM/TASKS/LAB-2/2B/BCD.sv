module binary_to_bcd (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd_out    // 3 BCD digits: [11:8][7:4][3:0]
);

logic [11:0] temp;
integer i;

always_comb begin
    temp = 12'b0;  

    // Double-Dabble algorithm
    for (i = 7; i >= 0; i--) begin
        // Add 3 if >= 5
        if (temp[3:0] >= 5)
            temp[3:0] = temp[3:0] + 3;
        if (temp[7:4] >= 5)
            temp[7:4] = temp[7:4] + 3;
        if (temp[11:8] >= 5)
            temp[11:8] = temp[11:8] + 3;

        // Shift left by 1 and bring in next binary bit
        temp = temp << 1;
        temp[0] = binary_in[i];
    end

    bcd_out = temp;  
end

endmodule

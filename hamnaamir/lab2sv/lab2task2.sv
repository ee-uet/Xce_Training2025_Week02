module binary_to_bcd(
    input  logic [7:0] binary_in,
    output logic [11:0] bcd_out
);
    always_comb begin
        logic [11:0] temp;
        int i;

        temp = 12'b0;

        for (i = 7; i >= 0; i = i - 1) begin
            // Add 3 to each nibble if >=5 before shifting
            if (temp[3:0] >= 5)   temp[3:0]  = temp[3:0]  + 3;
            if (temp[7:4] >= 5)   temp[7:4]  = temp[7:4]  + 3;
            if (temp[11:8] >= 5)  temp[11:8] = temp[11:8] + 3;

            // Shift left by 1 and bring in next bit
            temp = {temp[10:0], binary_in[i]};
        end

        bcd_out = temp;
    end
endmodule

module binary_to_bcd (
    input   logic [7 : 0]  binary_in,
    output  logic [11: 0] bcd_out   
);

    wire [19: 0] stage [0 : 8];
    assign stage[0] = {12'b0 , binary_in};

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : bcd_shift
            logic [19: 0] temp;
            always_comb begin
                temp = stage[i];
                if (temp[19:16] >= 5) temp[19:16] = temp[19:16] + 3;
                if (temp[15:12] >= 5) temp[15:12] = temp[15:12] + 3;
                if (temp[11: 8] >= 5) temp[11: 8] = temp[11: 8] + 3;
                stage[i+1] = temp << 1;
            end
        end
    endgenerate

    assign bcd_out = stage[8][19: 8];

endmodule
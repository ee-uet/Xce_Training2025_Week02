module BCDConverter (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd
);

    logic [19:0] bcd_temp;

    always_comb begin
        bcd_temp = {12'b0,binary_in};
        for (int i=0; i<8; i++) begin
            if (bcd_temp[11:8]  >= 5) bcd_temp[11:8]  = bcd_temp[11:8]  + 3;
            if (bcd_temp[15:12] >= 5) bcd_temp[15:12] = bcd_temp[15:12] + 3;
            if (bcd_temp[19:16] >= 5) bcd_temp[19:16] = bcd_temp[19:16] + 3;
            
            bcd_temp = bcd_temp << 1;
        end
    end

    assign bcd = bcd_temp[19:8];

endmodule

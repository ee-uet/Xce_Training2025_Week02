module bcd_comb (
    input  logic [7:0] data_in,
    output logic [3:0] bcd_out1,   // Ones
    output logic [3:0] bcd_out2,   // Tens
    output logic [3:0] bcd_out3    // Hundreds
);

    logic [3:0] bcd [2:0];   // internal BCD digits
    logic [7:0] data_shift;

    always_comb begin
        // init
        bcd[0] = 4'd0;
        bcd[1] = 4'd0;
        bcd[2] = 4'd0;
        data_shift = data_in;

        // perform 8 shifts (double dabble)
        for (int i=7; i>=0; i--) begin
            // add-3 correction
            for (int j=0; j<3; j++) begin
                if (bcd[j] >= 5)
                    bcd[j] = bcd[j] + 3;
            end
            // shift left {bcd, data_shift}
            {bcd[2], bcd[1], bcd[0], data_shift} = 
                {bcd[2], bcd[1], bcd[0], data_shift} << 1;
        end
    end

    // outputs
    assign bcd_out1 = bcd[0];
    assign bcd_out2 = bcd[1];
    assign bcd_out3 = bcd[2];

endmodule


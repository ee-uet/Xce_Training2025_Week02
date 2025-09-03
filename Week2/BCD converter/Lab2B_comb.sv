module binary_to_bcd (
    input  logic [7 : 0]  binary_in,
    output logic [11: 0] bcd_out
);

    // TOO: Implement Double-Dabble algorithm
    // Consider: Combinational loop approach
    var logic [19: 0] combine;
    always_comb begin
        combine = {12'b0 , binary_in};
        for (int i = 0; i < 8; i++) begin
            if (combine[11: 8] >= 4'b0101)  combine[11: 8] += 4'b0011;
            if (combine[15:12] >= 4'b0101)  combine[15:12] += 4'b0011;
            if (combine[19:16] >= 4'b0101)  combine[19:16] += 4'b0011;

            combine = combine << 1;
        end
            bcd_out = combine[19: 8];
    end
    
endmodule

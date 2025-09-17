module G2B #(
    parameter int N = 3
)(
    input  logic [N-1:0] gray,
    output logic [N-1:0] binary
);

    always_comb begin
        binary[N-1] = gray[N-1];
        for (int i = N-2; i >= 0; i--) begin
            binary[i] = gray[i] ^ binary[i+1];
        end
    end

endmodule

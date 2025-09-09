module binary2gray #(
    parameter N = 3
)
(
    input  logic [N-1:0] binary,
    output logic [N-1:0] gray
);
always_comb begin 
    gray = {binary[N-1], binary[N-1:1] ^ binary[N-2:0]};
    
end
endmodule
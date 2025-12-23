module g2b_converter #(parameter PTR_WIDTH=3) (
  input logic [PTR_WIDTH:0] gray_in,
  output logic [PTR_WIDTH:0] bin_out
);
  // Gray to Binary conversion: XOR all bits from MSB down to current bit
  always_comb begin
    bin_out[PTR_WIDTH] = gray_in[PTR_WIDTH];
    for (int i = PTR_WIDTH-1; i >= 0; i--) begin
      bin_out[i] = bin_out[i+1] ^ gray_in[i];
    end
  end
endmodule
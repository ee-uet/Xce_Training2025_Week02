module bit_detector (
    input logic div_clk,
    input logic rx_serial,
    output logic zero_detected
);
always_ff @(posedge div_clk) begin
    if (rx_serial == 1'b0) begin
        zero_detected = 1'b1;
    end else begin
        zero_detected = 1'b0;
    end
end

endmodule
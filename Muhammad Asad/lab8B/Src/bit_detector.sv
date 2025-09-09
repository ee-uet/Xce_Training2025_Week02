module bit_detector (
    input logic div_clk,
    input logic rx_serial,
    input logic rst_n,
    output logic zero_detected
);
always_ff @(posedge div_clk or negedge rst_n) begin
    if (!rst_n) begin
        zero_detected <= 1'b0;
    end
    else if (rx_serial == 1'b0) begin
        zero_detected <= 1'b1;
    end else begin
        zero_detected <= 1'b0;
    end
end

endmodule
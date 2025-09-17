module BitDetection (
    input  logic div_clk,
    input  logic rx_serial,
    input  logic rst_n,
    output logic start_bit_detected
);

    logic rx_d;

    always_ff @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_d <= 1'b1;                  // idle state of UART is 1
            start_bit_detected <= 1'b0;
        end else begin
            start_bit_detected <= (rx_d == 1'b1 && rx_serial == 1'b0); // 1→0 edge
            rx_d <= rx_serial;
        end
    end
endmodule

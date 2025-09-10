module baud16 #(
    parameter CLK_FREQ  = 50000000,   // System clock in Hz
    parameter BAUD_RATE = 115200      // UART baud rate
)(
    input  logic clk,
    input  logic reset,
    output logic baud_clk16   // 16x baud clock
);

    // Calculate divider
    localparam integer BAUD16_FREQ = BAUD_RATE * 16;
    localparam integer DIVISOR     = CLK_FREQ / (2*BAUD16_FREQ);
    // factor of 2 because we toggle output

    integer count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count      <= 0;
            baud_clk16 <= 0;
        end else begin
            if (count == DIVISOR-1) begin
                count      <= 0;
                baud_clk16 <= ~baud_clk16; // toggle
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule

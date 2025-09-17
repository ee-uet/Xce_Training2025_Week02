module ClkGenUART #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 25_000_000
)(
    input  logic clk,
    input  logic rst_n,
    output logic div_clk   // toggling clock
);

    localparam integer DIVISOR = CLK_FREQ / (2*BAUD_RATE);
    logic [$clog2(DIVISOR)-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            div_clk <= 0;
        end else if (counter == DIVISOR-1) begin
            counter <= 0;
            div_clk <= ~div_clk; // toggle
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

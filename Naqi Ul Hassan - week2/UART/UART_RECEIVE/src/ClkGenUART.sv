module ClkGenUART #(
    parameter CLK_FREQ  = 50_000_000,   // Input clock frequency
    parameter BAUD_RATE = 25_000_000    // Desired output clock frequency
)(
    input  logic clk,
    input  logic rst_n,
    output logic div_clk                  // 50% duty cycle divided clock
);

    localparam integer DIV_COUNT = CLK_FREQ / (2 * BAUD_RATE);
    logic [$clog2(DIV_COUNT)-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter  <= 0;
            div_clk  <= 0;
        end else if (counter == DIV_COUNT-1) begin
            counter <= 0;
            div_clk <= ~div_clk;        // Toggle output clock
        end else begin
            counter <= counter + 1;
        end
    end

endmodule

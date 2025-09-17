module Clk_Gen_Prescaler (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] prescale_val,
    output logic        prescaled_clk
);

    logic [15:0] count;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count         <= 16'd0;
            prescaled_clk <= 1'b0;
        end else if (count == prescale_val - 1) begin
            count         <= 16'd0;
            prescaled_clk <= ~prescaled_clk;
        end else
            count <= count + 1'b1;
    end

endmodule

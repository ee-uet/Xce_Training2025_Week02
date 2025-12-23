module Prescaler (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] prescale_val,   
    output logic        prescaled_clk   
);

    logic [15:0] count;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count         <= 0;
            prescaled_clk <= 0;
        end else begin
            if (count == prescale_val - 1) begin
                count         <= 0;
                prescaled_clk <= ~prescaled_clk; 
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
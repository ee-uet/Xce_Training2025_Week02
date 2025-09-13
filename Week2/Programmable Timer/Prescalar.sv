module Prescaler (
    input  logic        clk,           // Input clock
    input  logic        reset_n,       // Active-low asynchronous reset
    input  logic [15:0] prescale_val,  // Division factor
    output logic        prescaled_clk  // Output divided clock
);

    logic [15:0] count;

    // ------------------------------------------------------------
    // Clock divider (Prescaler)
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count         <= 16'd0;
            prescaled_clk <= 1'b0;
        end 
        else begin
            if (count == prescale_val - 1) begin
                count         <= 16'd0;
                prescaled_clk <= ~prescaled_clk; 
            end 
            else begin
                count <= count + 16'd1;
            end
        end
    end

endmodule

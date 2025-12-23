module clk_generator #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 25_000_000


)(
    input logic clk,
    input logic rst_n,
    output logic div_clk
);

logic [31:0] counter;
always_ff @(posedge clk or negedge rst_n)  begin
    if (!rst_n) begin
        counter <= 0;
        div_clk <= 0;
    end else if (counter >= CLK_FREQ) begin
        div_clk <= 1;
        counter <= counter - CLK_FREQ;
    end else begin
        counter <= counter + BAUD_RATE;
        div_clk <= 0;
    end
    
end
endmodule
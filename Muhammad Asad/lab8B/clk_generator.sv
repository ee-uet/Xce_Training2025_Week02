module clk_generator #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200


)(
    input logic clk,
    input logic rst_n,
    output logic div_clk,
);

int logic [31:0] counter;
always_ff @(posedge clk)  begin
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
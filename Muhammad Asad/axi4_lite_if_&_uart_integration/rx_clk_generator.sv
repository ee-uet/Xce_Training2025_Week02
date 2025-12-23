module rx_clk_generator #(
    parameter CLK_FREQ = 50_000_000
)(
    input logic        clk,
    input logic        rst_n,
    input logic [31:0] baud_rate,
    output logic       div_clk
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
        counter <= counter + baud_rate;
        div_clk <= 0;
    end
    
end
endmodule
module baud#(
    parameter int CLK_FREQ  = 50000000,
    parameter int BAUD_RATE = 115200
)(
    input  logic clk,
    input  logic rst_n,
    output logic baud_clk   // continuous clock at baud rate
);

    localparam int DIVISOR = CLK_FREQ / (BAUD_RATE );
    // *2 isliye, kyunki toggle karte waqt full period complete hoga

    logic [$clog2(DIVISOR)-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            counter  <= 0;
            baud_clk <= 0;
        end else begin
            if (counter == DIVISOR-1) begin
                counter  <= 0;
                baud_clk <= ~baud_clk;  // toggle
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule


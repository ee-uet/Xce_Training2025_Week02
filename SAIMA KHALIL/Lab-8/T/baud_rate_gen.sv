module baud_rate_gen #(
    parameter int CLK_FREQ  = 50000000,  // system clock frequency
    parameter int BAUD_RATE = 115200       // desired baud rate
)(
    input  logic clk,
    input  logic rst_n,
    output logic baud_tick   // 1-cycle pulse at baud rate
);

    localparam int DIVISOR = CLK_FREQ / BAUD_RATE;

    logic [$clog2(DIVISOR)-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == DIVISOR-1) begin
                counter   <= 0;
                baud_tick <= 1;  // ek clock cycle ka pulse
            end else begin
                counter   <= counter + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule

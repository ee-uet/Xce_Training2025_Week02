module timer #(
    parameter WIDTH = 6  // enough for 0–63 seconds
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,        // reset timer when high
    output logic [WIDTH-1:0] count   // current seconds
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (start)
            count <= 0;
        else
            count <= count + 1;
    end
endmodule

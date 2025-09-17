module Syncgen #(
    parameter int N = 3
)(
    input  logic          clk_dest,
    input  logic          rst_n,
    input  logic [N-1:0]  data_in,
    output logic [N-1:0]  data_out
);

    logic [N-1:0] sync_ff1, sync_ff2;

    always_ff @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= '0;
            sync_ff2 <= '0;
        end else begin
            sync_ff1 <= data_in;
            sync_ff2 <= sync_ff1;
        end
    end

    assign data_out = sync_ff2;

endmodule

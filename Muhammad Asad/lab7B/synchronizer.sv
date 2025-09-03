module synchronizer #(
    parameter N = 3
)(
    input  logic            clk_dest,
    input  logic            rst_n,
    input  logic [N-1:0]    data_in,
    output logic [N-1:0]    data_out
);

    logic [N-1:0] sync_reg [1:0];

    always_ff @(posedge clk_dest or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg[0] <= '0;
            sync_reg[1] <= '0;
        end else begin
            sync_reg[0] <= data_in;
            sync_reg[1] <= sync_reg[0];
        end
    end

    assign data_out = sync_reg[1];
endmodule
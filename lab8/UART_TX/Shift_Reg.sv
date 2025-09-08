module Shift_Reg (
    input logic clk,rst_n,shift_en,shift_reg_en,parity,
    input logic [7:0]data,
    output logic tx_serial
);
    logic [10:0]shift_reg;
    always_ff @( posedge clk ) begin : blockName
        if (!rst) begin
            shift_reg[0] <=1;
            shift_reg[10]<=0;
        end
        if (shift_reg_en) begin
            shift_reg[8:1]<=data;
            shift_reg[9]<=parity;
        end
        if (shift_en) begin
            shift_reg<={shift_reg[0],shift_reg[10:1]};
        end
    end
    assign tx_serial=shift_reg[0];
endmodule
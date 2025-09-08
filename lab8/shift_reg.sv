module Shift_Reg (
    input logic clk,
    input logic rst_n,
    input logic [7:0] tx_data,
    input logic parity,
    input logic shift_reg_en,
    input logic shift_en,
    output logic tx_bits
);
    logic [10:0]shift_reg;
    always_ff @( posedge clk ) begin : blockName
        if (!rst_n) begin
            shift_reg[0] <=1'b1;
            shift_reg[10]<=1'b0;
        end else begin
            if (shift_reg_en) begin
            shift_reg[8:1]<=tx_data;
            shift_reg[9]<=parity;
            end 
            if (shift_en) begin
                shift_reg<={shift_reg[]}
            end
        end
    end
endmodule
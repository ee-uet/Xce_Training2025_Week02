module Shift_Reg (
    input logic clk,rst_n,shift_en,shift_reg_en,parity,
    input logic [7:0]data,
    output logic tx_serial
);
    typedef struct packed {
        logic stop_bit;
        logic parity_bit;
        logic [7:0]rx_data;
        logic start_bit;
    } shift_register;
    shift_register shift_reg;
    always_ff @( negedge clk ) begin : blockName
        if (!rst_n) begin
            shift_reg.stop_bit <=1;
            shift_reg.start_bit<=1;
        end
        if (shift_reg_en) begin
            shift_reg.rx_data<=data;
            shift_reg.parity_bit<=parity;
            shift_reg.start_bit<=0;
            shift_reg.stop_bit <=1;
        end
        if (shift_en) begin
            shift_reg<={shift_reg[0],shift_reg[10:1]};
        end
    end
    assign tx_serial=shift_reg[0];
endmodule
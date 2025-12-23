import pkg::*;
module uart_status_reg (
    input logic clk,rst_n,parity_error,stop_bit_error,
    input uart_status_reg_en uart_status_en,
    output logic parity_error_o,stop_bit_error_o
);
    typedef struct packed {
        logic Parity_bit_error;
        logic Stop_bit_error;
    } uart_status_reg;
    uart_status_reg status_reg;
    always_ff @( posedge clk ) begin : blockName
        if (rst_n) begin
            status_reg=2'b0;
        end else begin
            status_reg.Parity_bit_error=(uart_status_en.parity_bit) ? parity_error:status_reg.Parity_bit_error;
            status_reg.Stop_bit_error=(uart_status_en.stop_bit) ? stop_bit_error:status_reg.Stop_bit_error;
        end
    end

    assign parity_error_o  =status_reg.Parity_bit_error;
    assign stop_bit_error_o=status_reg.Stop_bit_error;
endmodule
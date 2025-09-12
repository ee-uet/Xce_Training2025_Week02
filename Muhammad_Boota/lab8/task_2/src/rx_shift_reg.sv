module rx_shift_reg (
    input logic clk,rst_n,data_in,rx_shift_reg_en,
    output logic [7:0] fifo_Rx_Data
);
logic [7:0] rx_shift_reg;
assign fifo_Rx_Data=rx_shift_reg;

always_ff @( posedge clk ) begin 
    if (!rst_n)begin
        rx_shift_reg<=8'b0;
    end
    else if (rx_shift_reg_en) begin
        rx_shift_reg <= {data_in, rx_shift_reg[7:1]};
    end
end
endmodule
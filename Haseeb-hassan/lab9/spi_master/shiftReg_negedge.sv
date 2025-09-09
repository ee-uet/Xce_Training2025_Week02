module shiftReg_negedge (
    input logic spi_clk,
    input logic rst_n,
    input logic [7:0] tx_data,
    input logic shift_en_negedge,
    input logic load_en,
    output logic mosi
);
logic [7:0] shift_reg;
always_ff @(negedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
        mosi        <= 1'b0;
        shift_reg   <= 8'b0;
    end else if (shift_en_negedge) begin
        mosi <= shift_reg[7];
        shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left and fill LSB with 0
    end
    
    
end
endmodule
always_comb begin
     if (load_en) begin
        shift_reg <= tx_data;
    end
end
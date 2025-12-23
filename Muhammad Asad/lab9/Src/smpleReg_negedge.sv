module smpleReg_negedge (
    input logic spi_clk,
    input logic rst_n,
    input logic smple_en_negedge,
    input logic miso,
    input logic done,
    output logic [7:0] rx_data
);
logic [7:0] smple_reg;
always_ff @(negedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
        smple_reg <= 8'b0;
       // rx_data   <= 8'b0;
    end else if (smple_en_negedge) begin
        smple_reg <= {smple_reg[6:0], miso}; // Shift left and sample MISO
    end
    else begin
        smple_reg <= smple_reg;
    end
end
always_comb begin
    if (done) begin
        rx_data = smple_reg; 
    end  
    else begin
        rx_data = 8'b0;
    end
end
endmodule
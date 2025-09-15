module shiftReg_posedge (
    input logic clk,
    input logic spi_clk,
    input logic rst_n,
    input logic [7:0] tx_data,
    input logic shift_en_posedge,
    input logic load_en,

    input logic latch_data_en,
    output logic mosi
);
logic [7:0] shift_reg;
logic [7:0] tx_data_latched;
logic check;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_data_latched <= 8'b0;
        
    
    end 
    else if (load_en) begin
        tx_data_latched <= tx_data; 
            
    end
end
always_ff @(posedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
        mosi      <= 1'b0;
        shift_reg <= 8'b0;
        check <= 0;
    end    
    else if (latch_data_en && !check) begin
        shift_reg <= tx_data_latched;
        check <= 1;
    end 
        
    else if (shift_en_posedge) begin
        mosi <= shift_reg[7];
        shift_reg <= {shift_reg[6:0], 1'b0};
        
    end
end

/*
always_comb begin
     if (load_en) begin
        shift_reg_ff <= tx_data;
    end
end
*/
endmodule



/*
module shiftReg_posedge (
    input logic spi_clk,
    input logic rst_n,
    input logic [7:0] tx_data,
    input logic shift_en_posedge,
    input logic load_en,
    output logic mosi
);
logic [7:0] shift_reg;
always_ff @(posedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
        mosi      <= 1'b0;
        shift_reg <= 8'b0;
    end 
    else if (load_en) begin
        shift_reg <= tx_data;
    end
    else if (shift_en_posedge) begin
        mosi <= shift_reg[7];
        shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left and fill LSB with 0
    end
    
end

always_comb begin
    if (load_en) begin
        shift_reg <= tx_data;
    end
end 
endmodule
*/
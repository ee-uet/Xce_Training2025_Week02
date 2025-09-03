module address_logic (
    input logic [31:0] cpu_addr,
    output logic [3:0] in_ddr_bank,
    output logic [15:0] in_ddr_row,
    output logic [7:0] in_ddr_col
);
    // Assuming a simple mapping for demonstration purposes
always_comb begin
    in_ddr_bank = cpu_addr[31:28]; // Bits [31:28] → Bank (4 bits → 16 banks)
    in_ddr_row  = cpu_addr[27:12]; // Bits [27:12] → Row (16 bits → 65K rows per bank)
    in_ddr_col  = cpu_addr[11:4]; // Bits [11:4] → Column (8 bits → 256 columns per row)
end

//Bits [3:0] → Byte offset inside word
endmodule
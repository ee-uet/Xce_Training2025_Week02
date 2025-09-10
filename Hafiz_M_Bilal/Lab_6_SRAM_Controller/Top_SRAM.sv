module Top_SRAM(
	input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req, //For data read
    input  logic        write_req, // For data write
    input  logic [14:0] address, // where data whould be stored in SRAM
    input  logic [15:0] write_data, // This Data is written in SRAM
    output logic [15:0] read_data, // Data from SRAM
    output logic        ready
);

    logic [14:0] sram_addr;
    wire  [15:0] sram_data;   
    logic        sram_ce_n;
    logic        sram_oe_n;
    logic        sram_we_n;
	
	SRAM_Controller controller(	
								.clk(clk),
								.rst_n(rst_n),
								.read_req(read_req),
								.write_req(write_req),
								.address(address),
								.write_data(write_data),
								.read_data(read_data),
								.ready(ready),
								.sram_data(sram_data),
								.sram_we_n(sram_we_n),
								.sram_ce_n(sram_ce_n),
								.sram_oe_n(sram_oe_n),
								.sram_addr(sram_addr)
	);

	SRAM S_RAM(
				.clk(clk),
				.rst_n(rst_n),
				.sram_addr(sram_addr),
				.sram_oe_n(sram_oe_n),
                .sram_ce_n(sram_ce_n),
                .sram_we_n(sram_we_n),
                .sram_data(sram_data)
	);

endmodule
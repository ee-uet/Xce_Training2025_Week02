module Sram_datapath ( 
    input  logic        clk,
    input  logic        rst_n,

    // request signals
    input  logic        read_req,
    input  logic        write_req,

    // cpu side
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    
    // fsm control
    input  logic        latch_addr,
    input  logic        latch_data,
    input  logic        latch_read,
    input  logic        drive_data_en,

    // sram side
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data
);

    // internal latches
    logic [14:0] addr_reg;
    logic [15:0] write_reg;
    logic [15:0] read_reg;
    
    // capture address
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            addr_reg <= '0;
        else if (latch_addr)
            addr_reg <= address;
    end

    // capture data to write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_reg <= '0;
        else if (latch_data)
            write_reg <= write_data;
    end

    // capture data from sram
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_reg <= '0;
        else if (latch_read)
            read_reg <= sram_data; 
    end

    // outputs
    assign sram_addr = addr_reg;       // address to sram
    assign read_data = read_reg;       // data back to cpu
    assign sram_data = drive_data_en   // drive bus or float
                     ? write_reg 
                     : 16'bz;  

endmodule

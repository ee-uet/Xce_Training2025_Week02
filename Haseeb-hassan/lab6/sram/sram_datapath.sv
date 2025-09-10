module sram_datapath ( 
    input  logic        clk,
    input  logic        rst_n,

    // Requests
    input  logic        read_req,
    input  logic        write_req,

    // CPU-side interface
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,
    
    // Control signals from FSM
    input  logic        latch_addr,
    input  logic        latch_data,
    input  logic        latch_read,
    input  logic        drive_data_en,
    input  logic        fsm_ready,

   // input  logic        sram_ce_n_in,
    //input  logic        sram_oe_n_in,
   // input  logic        sram_we_n_in,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data
  //  output logic        sram_ce_n,
  //  output logic        sram_oe_n,
  //  output logic        sram_we_n
);

    // Internal registers
    logic [14:0] addr_reg;
    logic [15:0] write_reg;
    logic [15:0] read_reg;

    // Address latch
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            addr_reg <= '0;
        else if (latch_addr)
            addr_reg <= address;
    end

    // Write data latch
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_reg <= '0;
        else if (latch_data)
            write_reg <= write_data;
    end

    // Read data latch
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_reg <= '0;
        else if (latch_read)
            read_reg <= sram_data; // Capture from SRAM bus
    end

    // Output assignments
    assign sram_addr = addr_reg;
    assign read_data = read_reg;

    // Drive SRAM data bus during WRITE
    assign sram_data = (drive_data_en) ? write_reg : 16'bz;  //high impedance

    // Control signals pass-through from FSM
  //  assign sram_ce_n = sram_ce_n_in;
    //assign sram_oe_n = sram_oe_n_in;
    //assign sram_we_n = sram_we_n_in;

    // Ready comes from FSM
    assign ready = fsm_ready;

endmodule

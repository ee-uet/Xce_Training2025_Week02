module Top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // sram chip pins
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce,
    output logic        sram_oe,
    output logic        sram_we
);

    // control: fsm → datapath
    logic drive_data_en;
    logic latch_addr;
    logic latch_data;
    logic latch_read;

    // fsm
    Sram_fsm u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .read_req     (read_req),
        .write_req    (write_req),
        .latch_addr   (latch_addr),
        .latch_data   (latch_data),
        .latch_read   (latch_read),
        .drive_data_en(drive_data_en),
        .sram_ce_n    (sram_ce),   // note: active low
        .sram_oe_n    (sram_oe),   // note: active low
        .sram_we_n    (sram_we),   // note: active low
        .ready        (ready)
    );

    // datapath
    Sram_datapath u_datapath (
        .clk          (clk),
        .rst_n        (rst_n),

        // cpu side
        .read_req     (read_req),
        .write_req    (write_req),
        .address      (address),
        .write_data   (write_data),
        .read_data    (read_data),
           
        // fsm side
        .latch_addr   (latch_addr),
        .latch_data   (latch_data),
        .latch_read   (latch_read),
        .drive_data_en(drive_data_en),

        // sram side
        .sram_addr    (sram_addr),
        .sram_data    (sram_data)
    );

endmodule

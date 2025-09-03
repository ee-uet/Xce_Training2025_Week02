/*
        SRAM controller Implementation
*/

module top_module (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM chip pins
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n
);

    // Control wires FSM → Datapath
    logic drive_data_en;
    logic latch_addr;
    logic latch_data;
    logic latch_read;
    logic fsm_ready;

    // FSM instance
    sram_fsm u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .read_req     (read_req),
        .write_req    (write_req),
        .ready        (fsm_ready),
        .latch_addr   (latch_addr),
        .latch_data   (latch_data),
        .latch_read   (latch_read),
        .drive_data_en(drive_data_en),
        .sram_ce_n    (sram_ce_n),
        .sram_oe_n    (sram_oe_n),
        .sram_we_n    (sram_we_n)
    );

    // Datapath instance
    sram_datpath u_datapath (
        .clk(clk),
    .rst_n(rst_n),

    // CPU interface
    .read_req(read_req),
    .write_req(write_req),
    .address(address),
    .write_data(write_data),
    .read_data(read_data),
    .ready(ready),   

    // Control from FSM
    .latch_addr(latch_addr),
    .latch_data(latch_data),
    .latch_read(latch_read),
    .drive_data_en(drive_data_en),
    .fsm_ready(fsm_ready),

    .sram_ce_n_in(sram_ce_n_in),
    .sram_oe_n_in(sram_oe_n_in),
    .sram_we_n_in(sram_we_n_in),

    // SRAM side
    .sram_addr(sram_addr),
    .sram_data(sram_data),
    .sram_ce_n(sram_ce_n),
    .sram_oe_n(sram_oe_n),
    .sram_we_n(sram_we_n)
    );

endmodule

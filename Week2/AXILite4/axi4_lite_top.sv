module axi4_lite_top (
    input  logic clk,
    input  logic rst_n
);

    // Instantiate AXI4-Lite interface
    axi4_lite_if axi_bus (
        .aclk  (clk),
        .rst_n (rst_n)
    );

    // Master instance drives AXI bus
    axi4_lite_master master_inst (
        .axi_m (axi_bus.master)
    );

    // Slave instance responds on AXI bus
    axi4_lite_slave slave_inst (
        .axi_s (axi_bus.slave)
    );

endmodule

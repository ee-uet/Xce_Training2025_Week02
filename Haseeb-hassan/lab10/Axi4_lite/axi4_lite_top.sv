module axi4_lite_top (
    input  logic        aclk,
    input  logic        rst_n,
    input  logic        write_req,
    input  logic [31:0] write_addr,
    input  logic [31:0] write_data,
    input  logic [3:0]  write_strb,
    output logic        write_done,
    output logic [1:0]  write_resp,
    input  logic        read_req,
    input  logic [31:0] read_addr,
    output logic        read_done,
    output logic [31:0] read_data,
    output logic [1:0]  read_resp
);

    axi4_lite_if  if_inst (
        .aclk(aclk),
        .rst_n(rst_n)
    );

    axi4_lite_master master_inst (
        .write_req   (write_req),
        .write_addr  (write_addr),
        .write_data  (write_data),
        .write_strb  (write_strb),
        .write_done  (write_done),
        .write_resp  (write_resp),

        .read_req    (read_req),
        .read_addr   (read_addr),
        .read_done   (read_done),
        .read_data   (read_data),
        .read_resp   (read_resp),

        .axi_if(if_inst)
    );

    // Instantiate AXI4-Lite slave
    axi4_lite_slave slave_inst (
        .axi_if(if_inst)
    );

    

    
endmodule
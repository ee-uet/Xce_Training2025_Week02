module axi4_lite_top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        write_req,
    input  logic [31:0] write_address,
    input  logic [31:0] write_data,
    input  logic [3:0]  write_strb,
    output logic        write_done,
    output logic [1:0]  write_response,
    input  logic        read_req,
    input  logic [31:0] read_address,
    output logic        read_done,
    output logic [31:0] read_data,
    output logic [1:0]  read_response
);

    axi4_lite_if if_inst (
        .clk(clk),
        .rst_n(rst_n)
    );

    axi4_lite_master master_inst (
        .write_req      (write_req),
        .write_address  (write_address),
        .write_data     (write_data),
        .write_strb     (write_strb),
        .write_done     (write_done),
        .write_response (write_response),

        .read_req       (read_req),
        .read_address   (read_address),
        .read_done      (read_done),
        .read_data      (read_data),
        .read_response  (read_response),

        .axi_if         (if_inst)
    );

    axi4_lite_slave slave_inst (
        .axi_if(if_inst)
    );

endmodule

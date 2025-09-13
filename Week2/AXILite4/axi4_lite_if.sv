interface axi4lite_if (
    input  logic clk,
    input  logic rst_n
);

    // -------------------------------------------------------
    // Write Address Channel
    // -------------------------------------------------------
    logic [31:0] wr_addr;     // Write address
    logic        wr_addr_vld; // Write address valid
    logic        wr_addr_rdy; // Write address ready
    
    // -------------------------------------------------------
    // Write Data Channel
    // -------------------------------------------------------
    logic [31:0] wr_data;     // Write data
    logic [3:0]  wr_strb;     // Write strobes
    logic        wr_data_vld; // Write data valid
    logic        wr_data_rdy; // Write data ready
    
    // -------------------------------------------------------
    // Write Response Channel
    // -------------------------------------------------------
    logic [1:0]  wr_resp;     // Write response
    logic        wr_resp_vld; // Write response valid
    logic        wr_resp_rdy; // Write response ready
    
    // -------------------------------------------------------
    // Read Address Channel
    // -------------------------------------------------------
    logic [31:0] rd_addr;     // Read address
    logic        rd_addr_vld; // Read address valid
    logic        rd_addr_rdy; // Read address ready
    
    // -------------------------------------------------------
    // Read Data Channel
    // -------------------------------------------------------
    logic [31:0] rd_data;     // Read data
    logic [1:0]  rd_resp;     // Read response
    logic        rd_data_vld; // Read data valid
    logic        rd_data_rdy; // Read data ready

    // -------------------------------------------------------
    // Master Modport
    // -------------------------------------------------------
    modport master (
        output wr_addr, wr_addr_vld,
               wr_data, wr_strb, wr_data_vld,
               wr_resp_rdy,
               rd_addr, rd_addr_vld,
               rd_data_rdy,

        input  wr_addr_rdy, wr_data_rdy,
               wr_resp, wr_resp_vld,
               rd_addr_rdy,
               rd_data, rd_resp, rd_data_vld,

        input  clk, rst_n
    );

    // -------------------------------------------------------
    // Slave Modport
    // -------------------------------------------------------
    modport slave (
        input  wr_addr, wr_addr_vld,
               wr_data, wr_strb, wr_data_vld,
               wr_resp_rdy,
               rd_addr, rd_addr_vld,
               rd_data_rdy,

        output wr_addr_rdy, wr_data_rdy,
               wr_resp, wr_resp_vld,
               rd_addr_rdy,
               rd_data, rd_resp, rd_data_vld,

        input  clk, rst_n
    );

endinterface

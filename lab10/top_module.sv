/* 
    Implementation of AXI4 Lite
*/
module axi4_lite_top (
    input  logic        clk,
    input  logic        rst_n,
    
    // User interface for write transactions
    input  logic        write_req,      
    input  logic [31:0] write_addr,     
    input  logic [31:0] write_data,     
    input  logic [3:0]  write_strb,     
    output logic        write_done,     
    output logic [1:0]  write_resp,     
    
    // User interface for read transactions
    input  logic        read_req,       
    input  logic [31:0] read_addr,     
    output logic        read_done,     
    output logic [31:0] read_data,      
    output logic [1:0]  read_resp     
);

    // Instantiate the AXI4-Lite interface
    axi4_lite_if axi_bus();
    
    // Instantiate the AXI4-Lite master
    axi4_lite_master u_master (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_bus.master),
        
        // User interface connections
        .write_req(write_req),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strb(write_strb),
        .write_done(write_done),
        .write_resp(write_resp),
        
        .read_req(read_req),
        .read_addr(read_addr),
        .read_done(read_done),
        .read_data(read_data),
        .read_resp(read_resp)
    );
    
    // Instantiate the AXI4-Lite slave
    axi4_lite_slave u_slave (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_bus.slave)
    );

endmodule
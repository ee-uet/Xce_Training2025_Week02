/* 
    Integration of AXI4 Lite INTERFACE AND UART (TX & RX)
*/
module top_module (
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

    logic         tx_2_rx;
    axi4_lite_if  axi_bus();
    axi_uart_intf axi_uart_if();
    
    
    axi4_lite_master master (
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
    axi4_lite_slave slave (
        .clk(clk),
        .rst_n(rst_n),
        .axi_if(axi_bus.slave),
        .axi_slave_port(axi_uart_if.axi_slave)
    );
    // Instantiate the UART TX top module
    uart_tx_top_module #(
        .CLK_FREQ(50_000_000)
    ) uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_serial(tx_2_rx),
        .uart_tx_port(axi_uart_if.uart_tx)
    );
    // Instantiate the UART RX top module
    uartRX_top_module #(
        .CLK_FREQ(50_000_000)
    ) uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(tx_2_rx),
        .uart_rx_port(axi_uart_if.uart_rx)
    );

endmodule
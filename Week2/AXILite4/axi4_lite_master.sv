module axi4_lite_master (

    // Local interface for CPU/testbench
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
    output logic [1:0]  read_resp,

    
    axi4_lite_if.master  axi_if
);

    // FSM types
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;

    write_state_t write_state;
    read_state_t  read_state;

    
    always_ff @(posedge axi_if.aclk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            
            write_state     <= W_IDLE;
            axi_if.awaddr   <= 32'h0;
            axi_if.awvalid  <= 1'b0;
            axi_if.wdata    <= 32'h0;
            axi_if.wstrb    <= 4'h0;
            axi_if.wvalid   <= 1'b0;
            axi_if.bready   <= 1'b0;
            write_done      <= 1'b0;
            write_resp      <= 2'b00;
        end else begin
            
            write_done     <= 1'b0;
            

            case (write_state)
            
                W_IDLE: begin
                
                    axi_if.awvalid <= 1'b0;
                    axi_if.wvalid  <= 1'b0;
                    axi_if.bready  <= 1'b0;

                    if (write_req) begin
                        
                        axi_if.awaddr  <= write_addr;
                        axi_if.awvalid <= 1'b1;
                    
                        axi_if.wdata   <= write_data;
                        axi_if.wstrb   <= write_strb;
                        write_state    <= W_ADDR;
                    end
                end

                
                W_ADDR: begin
            
                    if (axi_if.awvalid && axi_if.awready) begin
                        // address accepted
                        axi_if.awvalid <= 1'b0;

                        
                        axi_if.wvalid <= 1'b1;
                        write_state   <= W_DATA;
                    end
                end

                
                W_DATA: begin
                    
                    if (axi_if.wvalid && axi_if.wready) begin
                        // data accepted
                        axi_if.wvalid <= 1'b0;

                        
                        axi_if.bready <= 1'b1;
                        write_state   <= W_RESP;
                    end
                end

                
                W_RESP: begin
                    
                    if (axi_if.bvalid) begin
                    
                        write_resp  <= axi_if.bresp;
                        write_done  <= 1'b1;  
                        axi_if.bready <= 1'b0;
                        write_state <= W_IDLE;
                    end
                end

                default: write_state <= W_IDLE;
            endcase
        end
    end

    
    always_ff @(posedge axi_if.aclk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            read_state   <= R_IDLE;
            axi_if.araddr <= 32'h0;
            axi_if.arvalid <= 1'b0;
            axi_if.rready  <= 1'b0;
            read_done      <= 1'b0;
            read_data      <= 32'h0;
            read_resp      <= 2'b00;
        end else begin
            
            read_done <= 1'b0;

            case (read_state)
                
                R_IDLE: begin
                    axi_if.arvalid <= 1'b0;
                    axi_if.rready  <= 1'b0;

                    if (read_req) begin
                    
                        axi_if.araddr  <= read_addr;
                        axi_if.arvalid <= 1'b1;
                        read_state     <= R_ADDR;
                    end
                end

                
                R_ADDR: begin
                    if (axi_if.arvalid && axi_if.arready) begin
                        // address accepted by slave
                        axi_if.arvalid <= 1'b0;
                        
                        axi_if.rready <= 1'b1;
                        read_state <= R_DATA;
                    end
                end

                
                R_DATA: begin
                    if (axi_if.rvalid && axi_if.rready) begin
                        
                        read_data <= axi_if.rdata;
                        read_resp <= axi_if.rresp;
                        read_done <= 1'b1;    // 1-cycle pulse
                        axi_if.rready <= 1'b0;
                        read_state <= R_IDLE;
                    end
                end

                default: read_state <= R_IDLE;
            endcase
        end
    end

endmodule

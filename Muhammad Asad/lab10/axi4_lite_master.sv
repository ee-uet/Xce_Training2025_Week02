module axi4_lite_master (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.master axi_if,
    
    // User interface for write transactions
    input  logic        write_req,      // Start write transaction
    input  logic [31:0] write_addr,     // Write address
    input  logic [31:0] write_data,     // Write data
    input  logic [3:0]  write_strb,     // Write strobes
    output logic        write_done,     // Write complete
    output logic [1:0]  write_resp,     // Write response
    
    // User interface for read transactions
    input  logic        read_req,       // Start read transaction  
    input  logic [31:0] read_addr,      // Read address
    output logic        read_done,      // Read complete
    output logic [31:0] read_data,      // Read data
    output logic [1:0]  read_resp       // Read response
);

typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;
typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
} read_state_t;
write_state_t c_write_state, n_write_state;
read_state_t c_read_state, n_read_state;

logic wr_addr_en, wr_data_en, wr_strb_en;
logic rd_addr_en, rd_data_en, rd_resp_en;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_write_state <= W_IDLE;
    end
    else begin
        c_write_state <= n_write_state;
    end
    
end
always_comb begin
    case (c_write_state) 
        W_IDLE: begin
            if (write_req) begin
                n_write_state <= W_ADDR;
            end
            else begin
                n_write_state <= W_IDLE;
            end
        end
        W_ADDR: begin
            n_write_state <= W_DATA;
        end
        W_DATA: begin
            if (axi_if.bvalid) begin
                n_write_state <= W_RESP;
            end
            else begin
                n_write_state <= W_DATA;
            end
        end
        W_RESP: begin
            n_write_state <= W_IDLE;
        end

            
    endcase
end
always_comb begin
    wr_addr_en = 0;
    write_done = 0;
    axi_if.awvalid = 0;
    wr_data_en = 0;
    axi_if.wvalid = 0;
    axi_if.bready = 0;
    write_resp = 0;
    wr_strb_en = 0;
    case (c_write_state) 
        W_IDLE: begin
            write_done = 1;
        end
        W_ADDR: begin
            wr_addr_en = 1;
            axi_if.awvalid = 1;
        end
        W_DATA: begin
            wr_data_en = 1;
            wr_strb_en = 1;
            axi_if.wvalid = 1;
            axi_if.bready = 1;
        end
        W_RESP: begin
            write_resp = axi_if.bresp;
        end

        

    endcase
end
always_comb begin
    axi_if.awaddr = 32'd0;
    if (wr_addr_en) begin
        axi_if.awaddr = write_addr;
    end
    else begin
        axi_if.awaddr = awaddr;
    end
    if (wr_data_en) begin
        axi_if.wdata = write_data;
    end
    else begin
        axi_if.wdata = axi_if.wdata;
    end
    if (wr_strb_en) begin
        axi_if.wstrb = write_strb;
    end
    else begin
        axi_if.wstrb = axi_if.wstrb;
    end
    
end

// read state machine
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_read_state <= R_IDLE;
    end
    else begin
        c_read_state <= n_read_state;
    end
end

always_comb begin
    case (c_read_state)
        R_IDLE: begin
            if (read_req) begin
                n_read_state = R_ADDR;
            end
            else begin
                n_read_state = R_IDLE;
            end
        end
        R_ADDR: begin
            if (axi_if.rvalid) begin
                n_read_state = R_DATA;
            end
            else begin
                n_read_state = R_ADDR;
            end
        end
        R_DATA: begin
            n_read_state = R_IDLE;
        end
    endcase
end
always_comb begin
    read_done = 0;
    rd_addr_en = 0;
    axi_if.arvalid = 0;
    axi_if.rready = 0;
    rd_resp_en = 0;
    case (c_read_state) 
        R_IDLE: begin
            read_done = 1;
        end
        R_ADDR: begin
            rd_addr_en = 1;
            axi_if.arvalid = 1;
            axi_if.rready = 1
        end
        R_DATA: begin
            rd_resp_en = 1;
        end


    endcase
end
always_comb begin
    axi_if.araddr = 32'd0;
    if (rd_addr_en) begin
        axi_if.araddr = read_addr;
    end
    else begin
        axi_if.araddr = axi_if.araddr;
    end
    if (rd_data_en) begin
        read_data = axi_if.rdata;
    end
    else begin
        read_data = 32'd0;
    end
    if (rd_resp_en) begin
        read_resp = axi_if.rresp;
    end
    else begin
        read_resp = 2'b00;
    end
end

endmodule
import pkg::*;
module axi4_lite_slave (
input logic clk,
input logic rst_n,axi4_lite_if.slave axi_if
);
// Register bank - 16 x 32-bit registers
logic [31:0] register_bank [0:15];
// Address decode
logic [3:0] write_addr_index, read_addr_index;
logic addr_valid_write, addr_valid_read;

write_state_t write_state,write_state_n;
read_state_t read_state,read_state_n;

// TODO: Implement write channel state machine
always_ff @( posedge clk ) begin 
    if (!rst_n) begin
        write_state <= IDEAL;
    end else begin
        write_state <= write_state_n;
    end
end

always_comb begin 
    case (write_state)
        W_IDLE:write_state_n=(axi_if.awvalid)? W_ADDR:W_IDLE;
        W_ADDR:write_state_n=W_DATA;
        W_DATA:write_state_n=(axi_if.wvalid)? W_RESP:W_DATA;
        W_RESP:write_state_n=(axi_if.bready)? W_IDLE:W_RESP;
        default: write_state_n=IDEAL;
    endcase
end

always_comb begin 
    axi_if.awready=1'b0;
    axi_if.wready=1'b0;
    bvalid=1'b0;
    bresp=2'b00;
    case (write_state)
        W_ADDR:axi_if.awready=1'b1;
        W_DATA:axi_if.wready=1'b1;
        W_RESP:begin
            axi_if.bvalid=1'b1;
            axi_if.bresp={(!addr_valid_write),1'b0};
        end
        default: begin
            axi_if.awready=1'b0;
            axi_if.wready=1'b0;
            axi_if.bvalid=1'b0;
            axi_if.bresp=2'b00;
        end
    endcase
end
// Consider: Outstanding transaction handling
// TODO: Implement read channel state machine
always_ff @( posedge clk ) begin 
    if (!rst_n) begin
        read_state <= IDEAL;
    end else begin
        read_state <= read_state_n;
    end
end
always_comb begin 
    case (read_state)
        R_IDLE:read_state_n=(axi_if.arvalid)? R_ADDR:R_IDLE;
        R_ADDR:read_state_n=W_DATA;
        R_DATA:read_state_n=(axi_if.rready)? R_IDLE:R_DATA;
        default: read_state_n=IDEAL;
    endcase
end

always_comb begin 
    axi_if.arready=1'b0;
    axi_if.rvalid=1'b0;
    axi_if.rresp=1'b0;
    case (read_state)
        R_ADDR:axi_if.arready=1'b1;
        R_DATA:begin 
            axi_if.rvalid=1'b1;
            axi_if.rresp={(!addr_valid_read),1'b0};
        end
        default:begin
            axi_if.arready=1'b0;
            axi_if.rvalid=1'b0;
            axi_if.rresp=1'b0;
        end
    endcase
end
// Consider: Read data pipeline timing
always_comb begin 
    if(addr_valid_read) begin
        axi_if.rdata=register_bank[read_addr_index];
    end else begin
        axi_if.rdata=1'b0;
    end
end
// TODO: Implement address decode logic
always_comb begin 
    if ((axi_if.araddr[31:4]==28'h9000)&& axi_if.arvalid) begin
        read_addr_index=axi_if.araddr[3:0];
        addr_valid_read=1'b1;
    end else begin
        read_addr_index=4'b0;
        addr_valid_read=1'b0;
    end
end
// Consider: What constitutes a valid address?
// TODO: Implement register bank
always_ff @( posedge clk ) begin : blockName
    if (!rst_n) begin
        register_bank <= '{default:0}; 
    end else if(addr_valid_write) begin
        register_bank[write_addr_index]<=axi_if.wdata;
    end
end
// Consider: Which registers are read-only vs read-write?
always_comb begin 
    if ((axi_if.awaddr[31:4]==29'h9000)&& axi_if.awvalid &&(axi_if.awaddr[4:3]==1'b0)) begin
        write_addr_index=axi_if.awaddr[2:0];
        addr_valid_write=1'b1;
    end else begin
        write_addr_index=4'b0;
        addr_valid_write=1'b0;
    end
end
endmodule
module axi4_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.slave  axi_if
);

    // Register bank - 16 x 32-bit registers
    logic [31:0] register_bank [0:15];
    
    // Address decode
    logic [3:0]     write_addr_index, read_addr_index;
    logic           addr_valid_write, addr_valid_read;
    logic [31:0]    wr_addr;
    logic           wr_addr_en, wr_data_en;
    logic           rd_addr_en, rd_data_en;
    logic [31:]     rd_addr;

    // State machines for read and write channels
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;
    
    
    

    write_state_t c_write_state, n_write_state;
    read_state_t c_read_state, n_read_state;
    // state register
    always_ff @(posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            c_write_state <= W_IDLE;
        end
        else begin
            c_write_state <= n_write_state;
        end
    end
    // next state logic
    always_comb begin
        case (c_write_state)
        W_IDLE: begin
            if (axi_if.awvalid) begin
                n_write_state <= W_ADDR;
            end
            else begin
                n_write_state <= W_IDLE;
            end
        end
        W_ADDR: begin
            if (axi_if.wvalid) begin
                n_write_state <= W_DATA;
            end
            else begin
                n_write_state <= W_ADDR;
            end
        end
        W_DATA: begin
            n_write_state <= W_RESP;
        end
        W_RESP: begin
            n_write_state <= W_IDLE;
        end

        endcase
        
    end
    // ouput logic
    always_comb begin
        axi_if.awready = 0;
        axi_if.wready = 0;
        wr_addr_en = 0;
        wr_data_en = 0;
        axi_if.bresp = 2'b00;
        axi_if.bvalid = 0;

        case (c_write_state)
        W_IDLE: begin
            if (axi_if.awvalid) begin
                wr_addr_en = 1;
            end
            axi_if.awready = 1;
        end
        W_ADDR: begin
            if (axi_if.wvalid) begin
                wr_data_en = 1;
            end
            axi_if.wready = 1;
            
        end
        W_DATA: begin
        end
        W_RESP: begin
            case (addr_valid_write)
            1'b0: begin                 // address is in valid
                axi_if.bresp = 2'b10;   //SLAVE ERROR
            end
            1'b1: begin
                axi_if.bresp = 2'b00;    // OKAY
            end
            axi_if.bvalid = 1;

            endcase
        end

        endcase
    end
    // synchronous address write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_addr <= 32'd0;
        end
        else if (wr_addr_en) begin
            wr_addr <= axi_if.awaddr;
        end
        else begin
            wr_addr <= wr_addr;
        end
    end

    always_comb begin
        // Valid addresses: 0x00, 0x04, 0x08, ..., 0x3C
        addr_valid_write = (wr_addr[31:6] == 26'h0) && (wr_addr[1:0] == 2'b00) && (wr_addr[5:0] >= 6'h00 && wr_addr[5:0] <= 6'h3C);
        write_addr_index = wr_addr[5:3];
        
    end
    // synchronous data write
    always_ff @(posedge clk) begin
        if (wr_data_en && addr_valid_write) begin //only write when wr_data_en && addr_valid_write both are 1
            for (int i = 0; i < 4; i++) begin
                if (axi_if.wstrb[i]) begin
                    register_bank[write_addr_index][i*8 +: 8] <= axi_if.wdata[i*8 +: 8];
                end
            end
        end
    end
    // read channel fsm
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c_read_state <= R_IDLE;
        end
        else begin
            c_read_state <= n_read_state;
        end
    end
    // next state logic
    always_comb begin
        case (c_read_state)
            R_IDLE: begin
                if (axi_if.arvalid) begin
                    n_read_state <= R_ADDR;
                end
                else begin
                    n_read_state <= R_IDLE;
                end
            end
            R_ADDR: begin
                if (axi_if.rready) begin
                    n_read_state <= R_DATA;
                end
                else begin
                    n_read_state <= R_ADDR;
                end
            end
            R_DATA: begin
                n_read_state <= R_IDLE;
            end
        endcase
        
    end
    // read output logic
    always_comb begin
        axi_if.arready = 0;
        rd_addr_en = 0;
        rd_data_en = 0;
        axi_if.rvalid = 0;
        axi_if.rresp = 2'b00;
        case (c_read_state)
            R_IDLE: begin
                if (axi_if.arvalid) begin
                    rd_addr_en = 1;
                end
                axi_if.arready = 1;
            end
            R_ADDR: begin
            end
            R_DATA: begin
                case (addr_valid_read) 
                    1'b0: axi_if.rresp = 2'b01; // SLAVE ERROR
                    1'b1: axi_if.rresp = 2'b00; // OKAY
                
                endcase
                rd_data_en = 1;
                axi_if.rvalid = 1;
                
            end
            
        endcase
    end
    // synchronous addr write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_addr <= 32'd0;
        end
        else if (rd_addr_en) begin
            rd_addr <= axi_if.araddr;
        end
        else begin
            rd_addr <= rd_addr;
        end
    end
    // read address decode logic
    always_comb begin
        addr_valid_read = (rd_addr[31:6] == 26'h0) && (rd_addr[1:0] == 2'b00) && (rd_addr[5:0] >= 6'h00 && rd_addr[5:0] <= 6'h3C);
        read_addr_index = rd_addr[5:3];
    end
    always_comb begin
        if (rd_data_en  && addr_valid_read) begin
            axi_if.rdata = register_bank[read_addr_index];
        end
        else begin
            axi_if.rdata = 32'd0;
        end
    end
    

endmodule


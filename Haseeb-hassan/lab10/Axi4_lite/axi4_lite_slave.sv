module axi4_lite_slave (
    axi4_lite_if.slave  axi_if
);

    // Register bank - 16 x 32-bit registers
    logic [31:0] register_bank [0:15];
    
    // Address decode
    logic [3:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read;
    logic [31:0] aw_offset, ar_offset;
    logic        aw_aligned, ar_aligned;
    logic        aw_in_range, ar_in_range;

    localparam int REG_COUNT   = 16;
    localparam int WORD_BYTES  = 4;      // bytes per register (32-bit)
    localparam int ADDR_LSB    = 2;      // log2(WORD_BYTES)
    localparam logic [31:0] BASE_ADDR = 32'h0000_0000;

    localparam logic [1:0] RESP_OKAY  = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    
    logic [REG_COUNT-1:0] reg_is_writable;

    // Address decode - combinational
    always_comb begin
        // defaults
        aw_offset      = 32'h0;
        ar_offset      = 32'h0;
        aw_aligned     = 1'b0;
        ar_aligned     = 1'b0;
        aw_in_range    = 1'b0;
        ar_in_range    = 1'b0;
        write_addr_index = 4'b0;
        read_addr_index  = 4'b0;
        addr_valid_write = 1'b0;
        addr_valid_read  = 1'b0;

        // AW decode
        aw_offset = axi_if.awaddr - BASE_ADDR;
        aw_aligned = (axi_if.awaddr[1:0] == 2'b00);
        aw_in_range = (axi_if.awaddr >= BASE_ADDR) &&
                      (aw_offset < (REG_COUNT * WORD_BYTES));
        if (aw_in_range)
            write_addr_index = aw_offset >> ADDR_LSB; 

        // AR decode
        ar_offset = axi_if.araddr - BASE_ADDR;
        ar_aligned = (axi_if.araddr[1:0] == 2'b00);
        ar_in_range = (axi_if.araddr >= BASE_ADDR) &&
                      (ar_offset < (REG_COUNT * WORD_BYTES));
        if (ar_in_range)
            read_addr_index = ar_offset >> ADDR_LSB;

        addr_valid_write = aw_aligned && aw_in_range;
        addr_valid_read  = ar_aligned && ar_in_range;
    end

    // State machines for read and write channels
    // I removed unused W_ADDR to avoid confusion (keep W_IDLE, W_DATA, W_RESP)
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR,W_DATA, W_RESP
    } write_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;
    
    write_state_t write_state;
    read_state_t  read_state;

    // Combined write/reset + register bank always_ff (single driver for register_bank)
    always_ff @(posedge axi_if.aclk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            
            register_bank[0] <= 32'h0000_0000; // control
            register_bank[1] <= 32'hABCD_1234; // status
            register_bank[2] <= 32'h0000_0000; // config
            register_bank[3] <= 32'h0001_0000; // version
            for (int i = 4; i < REG_COUNT; i++)
                register_bank[i] <= 32'h0;

            
            write_state     <= W_IDLE;
            axi_if.awready  <= 1'b0;
            axi_if.wready   <= 1'b0;
            axi_if.bvalid   <= 1'b0;
            axi_if.bresp    <= RESP_OKAY;

            
            reg_is_writable <= '1;
            reg_is_writable[1] <= 1'b0; // example: reg1 RO
            reg_is_writable[2] <= 1'b0; // example: reg3 RO
        end else begin
            // default outputs
            axi_if.awready <= 1'b0;
            axi_if.wready  <= 1'b0;
            // bvalid stays asserted until accepted

            // WRITE FSM
            case (write_state)
                W_IDLE: begin
                    axi_if.bvalid <= 1'b0;
                    if (axi_if.awvalid && !axi_if.bvalid) begin
                        
                        axi_if.awready <= 1'b1;
                      //  if (axi_if.awvalid && axi_if.awready) begin
                        write_state <= W_ADDR;
                  //  end
                    end
                end

                W_ADDR:begin
                    axi_if.wready <= 1'b1;
                    if (axi_if.wvalid && axi_if.wready) begin
                        write_state <= W_DATA;
                    end
                end

                W_DATA: begin
            
                        if (addr_valid_write && reg_is_writable[write_addr_index]) begin
                            for (int b = 0; b < 4; b++) begin
                                if (axi_if.wstrb[b])
                                    register_bank[write_addr_index][8*b +: 8] <= axi_if.wdata[8*b +: 8];
                            end
                            axi_if.bresp <= RESP_OKAY;
                        end else begin
                            
                            axi_if.bresp <= RESP_SLVERR;
                        end
                        axi_if.wready <= 1'b0;
                        axi_if.bvalid <= 1'b1;
                        write_state   <= W_RESP;
                    end
                

                W_RESP: begin
                    if (axi_if.bvalid && axi_if.bready) begin
                        axi_if.bvalid <= 1'b0;
                        write_state   <= W_IDLE;
                    end
                end

                default: write_state <= W_IDLE;
            endcase
        end
    end

    
    always_ff @(posedge axi_if.aclk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            read_state     <= R_IDLE;
            axi_if.arready <= 1'b0;
            axi_if.rvalid  <= 1'b0;
            axi_if.rresp   <= RESP_OKAY;
            axi_if.rdata   <= 32'h0;
        end else begin
            // defaults
            axi_if.arready <= 1'b0;

            case (read_state)
                R_IDLE: begin
                    axi_if.rvalid <= 1'b0;
                    if (axi_if.arvalid && !axi_if.rvalid) begin
                        
                        axi_if.arready <= 1'b1;
                        if (axi_if.arvalid && axi_if.arready) begin
                            
                            read_state <= R_ADDR;
                        end
                    end
                end

                R_ADDR: begin
                    
                    if (addr_valid_read) begin
                        axi_if.rdata <= register_bank[read_addr_index];
                        axi_if.rresp <= RESP_OKAY;
                    end else begin
                        axi_if.rdata <= 32'hDEAD_BEEF;
                        axi_if.rresp <= RESP_SLVERR;
                    end
                    axi_if.rvalid <= 1'b1;
                    read_state    <= R_DATA;
                end

                R_DATA: begin
                    if (axi_if.rvalid && axi_if.rready) begin
                        axi_if.rvalid <= 1'b0;
                        read_state    <= R_IDLE;
                    end
                end

                default: read_state <= R_IDLE;
            endcase
        end
    end

endmodule
/*
Suppose current register value = 0x11223344
Bytes: b3=0x11, b2=0x22, b1=0x33, b0=0x44

axi_if.wdata = 32'hAABBCCDD
Bytes: b3=0xAA, b2=0xBB, b1=0xCC, b0=0xDD

wstrb = 4'b0101 (b3 b2 b1 b0 = 0 1 0 1)

Loop behavior:

b=0: wstrb[0]=1 → update byte0 to 0xDD

b=1: wstrb[1]=0 → keep byte1 = 0x33

b=2: wstrb[2]=1 → update byte2 to 0xBB

b=3: wstrb[3]=0 → keep byte3 = 0x11

Resulting register = bytes (b3 b2 b1 b0) = 0x11 BB 33 DD → 0x11BB33DD.
*/
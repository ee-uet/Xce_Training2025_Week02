module axi4_lite_slave (
    input  logic            clk,
    input  logic            rst_n,
    axi4_lite_if.slave      axi_if 
);


    logic [31:0] register_bank [0:15];

 
    logic [3:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read;

    // 32-bit aligned word indices from byte address
    assign write_addr_index = axi_if.awaddr[5:2];
    assign read_addr_index  = axi_if.araddr[5:2];

    assign addr_valid_write = (axi_if.awaddr[1:0] == 2'b00) && (write_addr_index < 16);
    assign addr_valid_read  = (axi_if.araddr[1:0] == 2'b00) && (read_addr_index  < 16);

 
    typedef enum logic [1:0] { W_IDLE, W_ADDR, W_DATA, W_RESP } write_state_t;
    typedef enum logic [1:0] { R_IDLE, R_ADDR, R_DATA }         read_state_t;

    write_state_t write_state;
    read_state_t  read_state;

    // Sticky latches for write channel (to allow AW/W in any order)
    logic [31:0] awaddr_latched;
    logic        aw_captured;
    logic [31:0] wdata_latched;
    logic [3:0]  wstrb_latched;
    logic        w_captured;


    // Reset / init and FSMs

    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // AXI outputs
            axi_if.awready <= 1'b0;
            axi_if.wready  <= 1'b0;
            axi_if.bvalid  <= 1'b0;
            axi_if.bresp   <= 2'b00;

            axi_if.arready <= 1'b0;
            axi_if.rvalid  <= 1'b0;
            axi_if.rresp   <= 2'b00;
            axi_if.rdata   <= 32'h0;

            // FSMs
            write_state    <= W_IDLE;
            read_state     <= R_IDLE;

            // Latches
            awaddr_latched <= 32'h0;
            wdata_latched  <= 32'h0;
            wstrb_latched  <= 4'h0;
            aw_captured    <= 1'b0;
            w_captured     <= 1'b0;

            // clear register bank
            for (i = 0; i < 16; i++) begin
                register_bank[i] <= 32'h0;
            end
        end
        else begin

            // WRITE CHANNEL FSM
            unique case (write_state)
                W_IDLE: begin
                    // Ready to accept a new write txn
                    axi_if.awready <= !aw_captured; // READY=1 if we haven't captured AW yet
                    axi_if.wready  <= !w_captured;  // READY=1 if we haven't captured W yet
                    axi_if.bvalid  <= 1'b0;

                    // Capture AW when handshake happens
                    if (axi_if.awvalid && axi_if.awready) begin
                        awaddr_latched <= axi_if.awaddr;
                        aw_captured    <= 1'b1;
                    end
                    // Capture W when handshake happens
                    if (axi_if.wvalid && axi_if.wready) begin
                        wdata_latched <= axi_if.wdata;
                        wstrb_latched <= axi_if.wstrb;
                        w_captured    <= 1'b1;
                    end

                    // Move forward when both AW and W captured
                    if (aw_captured && w_captured) begin
                        axi_if.awready <= 1'b0;
                        axi_if.wready  <= 1'b0;
                        write_state    <= W_ADDR;
                    end
                end

                W_ADDR: begin
                    // We have latched address & data; go write
                    write_state <= W_DATA;
                end

                W_DATA: begin
                    // Perform the write with byte enables (if address valid)
                    if ((awaddr_latched[1:0] == 2'b00) && (awaddr_latched[5:2] < 16)) begin
                        for (int b = 0; b < 4; b++) begin
                            if (wstrb_latched[b]) begin
                                register_bank[awaddr_latched[5:2]][8*b +: 8] <= wdata_latched[8*b +: 8];
                            end
                        end
                        axi_if.bresp <= 2'b00; // OKAY
                    end
                    else begin
                        axi_if.bresp <= 2'b10; // SLVERR for invalid/unaligned
                    end

                    // Prepare response
                    axi_if.bvalid   <= 1'b1;
                    aw_captured     <= 1'b0;
                    w_captured      <= 1'b0;

                    write_state <= W_RESP;
                end

                W_RESP: begin
                    // Hold BVALID until BREADY
                    if (axi_if.bvalid && axi_if.bready) begin
                        axi_if.bvalid <= 1'b0;
                        write_state   <= W_IDLE;
                    end
                end
            endcase

           
            // READ CHANNEL FSM
            unique case (read_state)
                R_IDLE: begin
                    // Ready to accept a new read address when we're not holding RVALID
                    axi_if.arready <= !axi_if.rvalid;

                    if (axi_if.arvalid && axi_if.arready) begin
                        read_state    <= R_ADDR;
                        axi_if.arready<= 1'b0; // consume address
                    end
                end

                R_ADDR: begin
                    // Do address decode & fetch
                    if (addr_valid_read) begin
                        axi_if.rdata <= register_bank[read_addr_index];
                        axi_if.rresp <= 2'b00; // OKAY
                    end
                    else begin
                        axi_if.rdata <= 32'h0;
                        axi_if.rresp <= 2'b10; // SLVERR
                    end
                    axi_if.rvalid <= 1'b1;
                    read_state    <= R_DATA;
                end

                R_DATA: begin
                    // Hold data/resp stable until RREADY
                    if (axi_if.rvalid && axi_if.rready) begin
                        axi_if.rvalid <= 1'b0;
                        read_state    <= R_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
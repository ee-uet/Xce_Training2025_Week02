module axi4_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.slave  axi_if      // Instantiation of Slave Interface
);

    // Register bank - 16 x 32-bit registers
    logic [31:0] register_bank [0:15];

    // Address decode
    logic [3:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read;

    // State machines
    typedef enum logic [1:0] {
        W_IDLE, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_DATA
    } read_state_t;

    write_state_t write_state, write_state_next;
    read_state_t  read_state,  read_state_next;

    // Latched indices
    logic [3:0] latched_windex;
    logic [3:0] latched_rindex;

    // Write enable
    logic write_en;

    // ------------------------------------------------------------
    // Write channel FSM
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_state    <= W_IDLE;
            latched_windex <= '0;
        end else begin
            write_state    <= write_state_next;
            if (axi_if.awvalid && axi_if.awready)
                latched_windex <= axi_if.awaddr[5:2];
        end
    end

    always_comb begin

        unique case (write_state)

            W_IDLE: begin
                axi_if.awready = 1'b1; // accept address
                if (axi_if.awvalid && axi_if.awready)
                    write_state_next = W_DATA;
            end

            W_DATA: begin
                axi_if.wready = 1'b1;
                if (axi_if.wvalid && axi_if.wready) begin
                    write_en         = addr_valid_write;
                    write_state_next = W_RESP;
                end
            end

            W_RESP: begin
                axi_if.bvalid = 1'b1;
                axi_if.bresp  = addr_valid_write ? 2'b00 : 2'b11; // OKAY/DECERR
                if (axi_if.bvalid && axi_if.bready)
                    write_state_next = W_IDLE;
            end
            default: begin
            // Safe default
            axi_if.awready = 1'b0;
            axi_if.wready  = 1'b0;
            axi_if.bvalid  = 1'b0;
            axi_if.bresp   = 2'b00;
            write_en       = 1'b0;
            write_state_next = W_IDLE;
        end
        endcase
    end

    // ------------------------------------------------------------
    // Read channel FSM
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state    <= R_IDLE;
            latched_rindex <= '0;
        end else begin
            read_state    <= read_state_next;
            if (axi_if.arvalid && axi_if.arready)
                latched_rindex <= axi_if.araddr[5:2];
        end
    end

    always_comb begin
        // Defaults
        axi_if.arready = 1'b0;
        axi_if.rvalid  = 1'b0;
        axi_if.rresp   = 2'b00;
        axi_if.rdata   = 32'h0;
        read_state_next = read_state;

        unique case (read_state)

            default: begin
            // Safe default
            axi_if.arready = 1'b0;
            axi_if.rvalid  = 1'b0;
            axi_if.rresp   = 2'b00;
            axi_if.rdata   = 32'h0;
            read_state_next = R_IDLE;
            end
            R_IDLE: begin
                axi_if.arready = 1'b1;
                if (axi_if.arvalid && axi_if.arready)
                    read_state_next = R_DATA;
            end

            R_DATA: begin
                axi_if.rvalid = 1'b1;
                if (addr_valid_read) begin
                    axi_if.rdata = register_bank[latched_rindex];
                    axi_if.rresp = 2'b00; // OKAY
                end else begin
                    axi_if.rresp = 2'b11; // DECERR
                end

                if (axi_if.rvalid && axi_if.rready)
                    read_state_next = R_IDLE;
            end
        endcase
    end

    // ------------------------------------------------------------
    // Address decode
    // ------------------------------------------------------------
    parameter HIGH_ADDR = 'h0000_003C;
    parameter BASE_ADDR = 'h0000_0000;

    always_comb begin : decoder
        write_addr_index = axi_if.awaddr[5:2];
        addr_valid_write = (axi_if.awaddr[1:0] == 2'b00) && (axi_if.awaddr >= BASE_ADDR) && (axi_if.awaddr <= HIGH_ADDR);

        read_addr_index  = axi_if.araddr[5:2];
        addr_valid_read  = (axi_if.araddr[1:0] == 2'b00) && (axi_if.araddr >= BASE_ADDR) && (axi_if.araddr <= HIGH_ADDR);
    end

    // ------------------------------------------------------------
    // Register bank
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 16; i++)
                register_bank[i] <= 32'h0;
        end else if (write_en) begin
            for (int i = 0; i < 4; i++) begin
                if (axi_if.wstrb[i]) begin
                    register_bank[latched_windex][8*i +: 8] <= axi_if.wdata[8*i +: 8];
                end
            end
        end
    end

endmodule

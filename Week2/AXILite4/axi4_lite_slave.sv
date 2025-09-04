module axi4_lite_slave (
    axi4lite_if.slave axi_s
);

    // ------------------------------------------------------------------
    // Register file - 16 x 32-bit registers
    // ------------------------------------------------------------------
    logic [31:0] reg_file [0:15];

    // Address decode signals
    logic [3:0]  wr_addr_idx, rd_addr_idx;
    logic        wr_addr_valid, rd_addr_valid;
    logic [31:0] wr_offset, rd_offset;
    logic        wr_aligned, rd_aligned;
    logic        wr_in_range, rd_in_range;

    localparam int REG_TOTAL      = 16;
    localparam int BYTES_PER_WORD = 4;        // 32-bit per reg
    localparam int ADDR_SHIFT     = 2;        // log2(BYTES_PER_WORD)
    localparam logic [31:0] BASE_ADDR = 32'h0000_0000;

    localparam logic [1:0] RESP_OKAY  = 2'b00;
    localparam logic [1:0] RESP_ERROR = 2'b10;

    // Register write permissions (1 = writable, 0 = read-only)
    logic [REG_TOTAL-1:0] reg_writable;

    // ------------------------------------------------------------------
    // Address decode (combinational)
    // ------------------------------------------------------------------
    always_comb begin
        // defaults
        wr_offset      = 32'h0;
        rd_offset      = 32'h0;
        wr_aligned     = 1'b0;
        rd_aligned     = 1'b0;
        wr_in_range    = 1'b0;
        rd_in_range    = 1'b0;
        wr_addr_idx    = 4'b0;
        rd_addr_idx    = 4'b0;
        wr_addr_valid  = 1'b0;
        rd_addr_valid  = 1'b0;

        // Write address decode
        wr_offset   = axi_s.wr_addr - BASE_ADDR;
        wr_aligned  = (axi_s.wr_addr[1:0] == 2'b00);
        wr_in_range = (axi_s.wr_addr >= BASE_ADDR) &&
                      (wr_offset < (REG_TOTAL * BYTES_PER_WORD));
        if (wr_in_range)
            wr_addr_idx = wr_offset >> ADDR_SHIFT;

        // Read address decode
        rd_offset   = axi_s.rd_addr - BASE_ADDR;
        rd_aligned  = (axi_s.rd_addr[1:0] == 2'b00);
        rd_in_range = (axi_s.rd_addr >= BASE_ADDR) &&
                      (rd_offset < (REG_TOTAL * BYTES_PER_WORD));
        if (rd_in_range)
            rd_addr_idx = rd_offset >> ADDR_SHIFT;

        wr_addr_valid = wr_aligned && wr_in_range && axi_s.wr_addr_vld;
        rd_addr_valid = rd_aligned && rd_in_range && axi_s.rd_addr_vld;
    end

    // ------------------------------------------------------------------
    // FSM encodings
    // ------------------------------------------------------------------
    typedef enum logic [1:0] { WR_IDLE, WR_ADDR_ACCEPT, WR_DATA_ACCEPT, WR_RESP } wr_state_t;
    typedef enum logic [1:0] { RD_IDLE, RD_ADDR_ACCEPT, RD_DATA }              rd_state_t;

    wr_state_t wr_state;
    rd_state_t rd_state;

    // ------------------------------------------------------------------
    // Write channel (address/data/resp)
    // ------------------------------------------------------------------
    always_ff @(posedge axi_s.clk or negedge axi_s.rst_n) begin
        if (!axi_s.rst_n) begin
            // register defaults
            reg_file[0] <= 32'h0000_0000; // control (example)
            reg_file[1] <= 32'hABCD_1234; // status
            reg_file[2] <= 32'h0000_0000; // config
            reg_file[3] <= 32'h0001_0000; // version
            for (int i = 4; i < REG_TOTAL; i++)
                reg_file[i] <= 32'h0;

            // reset write FSM & outputs
            wr_state        <= WR_IDLE;
            axi_s.wr_addr_rdy <= 1'b0;
            axi_s.wr_data_rdy <= 1'b0;
            axi_s.wr_resp_vld <= 1'b0;
            axi_s.wr_resp     <= RESP_OKAY;

            // permissions: default all writable, selectively RO
            reg_writable <= '1;
            reg_writable[0] <= 1'b0; // control: RO example
            reg_writable[1] <= 1'b0; // status: RO
            reg_writable[2] <= 1'b0; // config: RO
            reg_writable[3] <= 1'b0; // version: RO
        end else begin
            // default: deassert ready signals; resp_vld remains until accepted
            axi_s.wr_addr_rdy <= 1'b0;
            axi_s.wr_data_rdy <= 1'b0;

            case (wr_state)
                // Master presents address (wr_addr & wr_addr_vld)
                WR_IDLE: begin
                    axi_s.wr_resp_vld <= 1'b0;
                    if (axi_s.wr_addr_vld && !axi_s.wr_resp_vld) begin
                        // accept address this cycle
                        axi_s.wr_addr_rdy <= 1'b1;
                        wr_state <= WR_ADDR_ACCEPT;
                    end
                end

                // After address accepted, wait for data
                WR_ADDR_ACCEPT: begin
                    // Keep addr_rdy low next cycle; present data-ready
                    axi_s.wr_data_rdy <= 1'b1;
                    if (axi_s.wr_data_vld && axi_s.wr_data_rdy) begin
                        // write data into register if address valid and writable
                        if (wr_addr_valid && reg_writable[wr_addr_idx]) begin
                            for (int b = 0; b < BYTES_PER_WORD; b++) begin
                                if (axi_s.wr_strb[b])
                                    reg_file[wr_addr_idx][8*b +: 8] <= axi_s.wr_data[8*b +: 8];
                            end
                            axi_s.wr_resp <= RESP_OKAY;
                        end else begin
                            axi_s.wr_resp <= RESP_ERROR;
                        end

                        // drive response valid until master accepts
                        axi_s.wr_data_rdy <= 1'b0;
                        axi_s.wr_resp_vld <= 1'b1;
                        wr_state <= WR_RESP;
                    end
                end

                // Present response and wait for master to accept (wr_resp_rdy)
                WR_RESP: begin
                    if (axi_s.wr_resp_vld && axi_s.wr_resp_rdy) begin
                        axi_s.wr_resp_vld <= 1'b0;
                        wr_state <= WR_IDLE;
                    end
                end

                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Read channel (address -> data)
    // ------------------------------------------------------------------
    always_ff @(posedge axi_s.clk or negedge axi_s.rst_n) begin
        if (!axi_s.rst_n) begin
            rd_state        <= RD_IDLE;
            axi_s.rd_addr_rdy <= 1'b0;
            axi_s.rd_data_vld <= 1'b0;
            axi_s.rd_resp     <= RESP_OKAY;
            axi_s.rd_data     <= 32'h0;
        end else begin
            // default: deassert ready; keep data_vld asserted until accepted
            axi_s.rd_addr_rdy <= 1'b0;

            case (rd_state)
                RD_IDLE: begin
                    axi_s.rd_data_vld <= 1'b0;
                    if (axi_s.rd_addr_vld && !axi_s.rd_data_vld) begin
                        // accept the read address
                        axi_s.rd_addr_rdy <= 1'b1;
                        rd_state <= RD_ADDR_ACCEPT;
                    end
                end

                RD_ADDR_ACCEPT: begin
                    // Address accepted; prepare read data and assert data valid
                    if (rd_addr_valid) begin
                        axi_s.rd_data <= reg_file[rd_addr_idx];
                        axi_s.rd_resp <= RESP_OKAY;
                    end else begin
                        axi_s.rd_data <= 32'hDEAD_BEEF;
                        axi_s.rd_resp <= RESP_ERROR;
                    end
                    axi_s.rd_data_vld <= 1'b1;
                    rd_state <= RD_DATA;
                end

                RD_DATA: begin
                    // Wait until master accepts read data via rd_data_rdy
                    if (axi_s.rd_data_vld && axi_s.rd_data_rdy) begin
                        axi_s.rd_data_vld <= 1'b0;
                        rd_state <= RD_IDLE;
                    end
                end

                default: rd_state <= RD_IDLE;
            endcase
        end
    end

endmodule

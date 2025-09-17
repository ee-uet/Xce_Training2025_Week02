module axi4_lite_slave (
    axi4_lite_if.slave axi_if
);

    // Register bank - 16 x 32-bit registers
    logic [31:0] register_bank [0:15];

    // Address decode
    logic [3:0]  write_addr_index, read_addr_index;
    logic        addr_valid_write, addr_valid_read;
    logic [31:0] write_offset, read_offset;
    logic        write_aligned, read_aligned;
    logic        write_in_range, read_in_range;

    localparam int REG_COUNT   = 16;
    localparam int WORD_BYTES  = 4;
    localparam int ADDR_LSB    = 2;
    localparam logic [31:0] BASE_ADDR = 32'h0000_0000;

    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    logic [REG_COUNT-1:0] reg_is_writable;

    // Address decode
    always_comb begin
        write_offset       = axi_if.write_address - BASE_ADDR;
        read_offset        = axi_if.read_address - BASE_ADDR;
        write_aligned      = (axi_if.write_address[1:0] == 2'b00);
        read_aligned       = (axi_if.read_address[1:0] == 2'b00);
        write_in_range     = (axi_if.write_address >= BASE_ADDR) &&
                             (write_offset < (REG_COUNT*WORD_BYTES));
        read_in_range      = (axi_if.read_address >= BASE_ADDR) &&
                             (read_offset < (REG_COUNT*WORD_BYTES));
        if (write_in_range) write_addr_index = write_offset >> ADDR_LSB;
        if (read_in_range)  read_addr_index  = read_offset  >> ADDR_LSB;
        addr_valid_write    = write_aligned && write_in_range;
        addr_valid_read     = read_aligned  && read_in_range;
    end

    // State machines
    typedef enum logic [1:0] { W_IDLE, W_ADDR, W_DATA, W_RESP } write_state_t;
    typedef enum logic [1:0] { R_IDLE, R_ADDR, R_DATA } read_state_t;

    write_state_t write_state;
    read_state_t  read_state;

    // Write FSM + register bank
    always_ff @(posedge axi_if.clk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            register_bank[0] <= 32'h0000_0000;
            register_bank[1] <= 32'hABCD_1234;
            register_bank[2] <= 32'h0000_0000;
            register_bank[3] <= 32'h0001_0000;
            for (int i=4; i<REG_COUNT; i++)
                register_bank[i] <= 32'h0;

            write_state                <= W_IDLE;
            axi_if.write_address_ready  <= 1'b0;
            axi_if.write_data_ready     <= 1'b0;
            axi_if.write_response_valid <= 1'b0;
            axi_if.write_response       <= RESP_OKAY;

            reg_is_writable <= '1;
            reg_is_writable[1] <= 1'b0;
            reg_is_writable[2] <= 1'b0;
        end else begin
            axi_if.write_address_ready  <= 1'b0;
            axi_if.write_data_ready     <= 1'b0;

            case (write_state)
                W_IDLE: begin
                    axi_if.write_response_valid <= 1'b0;
                    if (axi_if.write_address_valid && !axi_if.write_response_valid) begin
                        axi_if.write_address_ready <= 1'b1;
                        write_state <= W_ADDR;
                    end
                end

                W_ADDR: begin
                    axi_if.write_data_ready <= 1'b1;
                    if (axi_if.write_data_valid && axi_if.write_data_ready)
                        write_state <= W_DATA;
                end

                W_DATA: begin
                    if (addr_valid_write && reg_is_writable[write_addr_index]) begin
                        for (int b=0; b<4; b++)
                            if (axi_if.write_strb[b])
                                register_bank[write_addr_index][8*b +:8] <= axi_if.write_data[8*b +:8];
                        axi_if.write_response <= RESP_OKAY;
                    end else begin
                        axi_if.write_response <= RESP_SLVERR;
                    end
                    axi_if.write_data_ready     <= 1'b0;
                    axi_if.write_response_valid <= 1'b1;
                    write_state                 <= W_RESP;
                end

                W_RESP: begin
                    if (axi_if.write_response_valid && axi_if.write_response_ready) begin
                        axi_if.write_response_valid <= 1'b0;
                        write_state                 <= W_IDLE;
                    end
                end

                default: write_state <= W_IDLE;
            endcase
        end
    end

    // Read FSM
    always_ff @(posedge axi_if.clk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            read_state          <= R_IDLE;
            axi_if.read_address_ready <= 1'b0;
            axi_if.read_data_valid     <= 1'b0;
            axi_if.read_response        <= RESP_OKAY;
            axi_if.read_data            <= 32'h0;
        end else begin
            axi_if.read_address_ready <= 1'b0;

            case (read_state)
                R_IDLE: begin
                    axi_if.read_data_valid <= 1'b0;
                    if (axi_if.read_address_valid && !axi_if.read_data_valid) begin
                        axi_if.read_address_ready <= 1'b1;
                        read_state <= R_ADDR;
                    end
                end

                R_ADDR: begin
                    if (addr_valid_read) begin
                        axi_if.read_data     <= register_bank[read_addr_index];
                        axi_if.read_response <= RESP_OKAY;
                    end else begin
                        axi_if.read_data     <= 32'hDEAD_BEEF;
                        axi_if.read_response <= RESP_SLVERR;
                    end
                    axi_if.read_data_valid <= 1'b1;
                    read_state             <= R_DATA;
                end

                R_DATA: begin
                    if (axi_if.read_data_valid && axi_if.read_data_ready) begin
                        axi_if.read_data_valid <= 1'b0;
                        read_state             <= R_IDLE;
                    end
                end

                default: read_state <= R_IDLE;
            endcase
        end
    end

endmodule

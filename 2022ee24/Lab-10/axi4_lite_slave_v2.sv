module axi4_lite_slave_v2 (
    input  logic        clk,     
    input  logic        rst_n,   
    axi4_lite_if.slave  axi_if   
);

    // Memory map configuration
    localparam BASE_ADDR = 32'h4000_0000;
    logic [31:0] register_bank [0:15];  // 16 x 32-bit registers

    // Latched AXI signals
    logic [31:0] awaddr_latched; // Write address
    logic [3:0]  wstrb_latched;  // Write strobes
    logic [31:0] wdata_latched;  // Write data
    logic [31:0] araddr_latched; // Read address

    // Internal control signals
    logic        addr_valid_write, addr_valid_read;
    logic [3:0]  write_addr_index, read_addr_index;
    logic [1:0]  bresp_reg, rresp_reg;

    // State definitions
    typedef enum logic [1:0] {
        W_IDLE,   // Waiting for write
        W_ADDR,   // Processing write address
        W_DATA,   // Processing write data
        W_RESP    // Sending write response
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE,   // Waiting for read
        R_ADDR,   // Processing read address
        R_DATA    // Sending read data
    } read_state_t;

    // State registers
    write_state_t write_state, next_write_state;
    read_state_t  read_state, next_read_state;

    // Address decoding
    always_comb begin : write_addr_decoder
        addr_valid_write = (awaddr_latched[31:6] == BASE_ADDR[31:6]);
        write_addr_index = awaddr_latched[5:2];
    end

    always_comb begin : read_addr_decoder
        addr_valid_read = (araddr_latched[31:6] == BASE_ADDR[31:6]);
        read_addr_index = araddr_latched[5:2];
    end

    // Write FSM - Sequential
    always_ff @(posedge clk or negedge rst_n) begin : write_fsm_seq
        if (!rst_n) begin
            write_state <= W_IDLE;
            bresp_reg <= 2'b00;
        end else begin
            write_state <= next_write_state;
        end
    end

    // Write FSM - Combinational
    always_comb begin : write_fsm_comb
        next_write_state = write_state;
        axi_if.awready = 1'b0;
        axi_if.wready  = 1'b0;
        axi_if.bvalid  = 1'b0;
        axi_if.bresp   = 2'b00;

        case (write_state)
            W_IDLE: begin
                axi_if.awready = 1'b1;
                if (axi_if.awvalid) begin
                    next_write_state = W_ADDR;
                end
            end

            W_ADDR: begin
                axi_if.wready = 1'b1;
                if (axi_if.wvalid) begin
                    next_write_state = W_DATA;
                end
            end

            W_DATA: begin
                next_write_state = W_RESP;
            end

            W_RESP: begin
                axi_if.bvalid = 1'b1;
                axi_if.bresp = (!addr_valid_write) ? 2'b10 : 2'b00;
                
                if (axi_if.bready) begin
                    next_write_state = W_IDLE;
                end
            end
        endcase
    end

    // Latch write signals
    always_ff @(posedge clk) begin : latch_aw_signals
        if (write_state == W_IDLE && axi_if.awvalid && axi_if.awready) begin
            awaddr_latched <= axi_if.awaddr;
            wstrb_latched  <= axi_if.wstrb;
        end
    end

    always_ff @(posedge clk) begin : latch_w_signals
        if (write_state == W_ADDR && axi_if.wvalid && axi_if.wready) begin
            wdata_latched <= axi_if.wdata;
        end
    end

    // Register write logic with byte enables
    always_ff @(posedge clk or negedge rst_n) begin : register_write_process
        integer i;
        logic [31:0] current_value;
        logic [31:0] new_value;

        if (!rst_n) begin
            for (int i = 0; i < 16; i++) begin
                register_bank[i] <= 32'h0;
            end
        end else if (write_state == W_DATA && addr_valid_write) begin
            current_value = register_bank[write_addr_index];
            new_value = current_value;

            for (i = 0; i < 4; i++) begin
                if (wstrb_latched[i]) begin
                    new_value[i*8 +: 8] = wdata_latched[i*8 +: 8];
                end
            end
            
            register_bank[write_addr_index] <= new_value;
        end
    end

    // Read FSM - Sequential
    always_ff @(posedge clk or negedge rst_n) begin : read_fsm_seq
        if (!rst_n) begin
            read_state <= R_IDLE;
            rresp_reg <= 2'b00;
        end else begin
            read_state <= next_read_state;
        end
    end

    // Read FSM - Combinational
    always_comb begin : read_fsm_comb
        next_read_state = read_state;
        axi_if.arready = 1'b0;
        axi_if.rvalid  = 1'b0;
        axi_if.rresp   = 2'b00;

        case (read_state)
            R_IDLE: begin
                axi_if.arready = 1'b1;
                if (axi_if.arvalid) begin
                    next_read_state = R_ADDR;
                end
            end

            R_ADDR: begin
                next_read_state = R_DATA;
            end

            R_DATA: begin
                axi_if.rvalid = 1'b1;
                axi_if.rresp = (!addr_valid_read) ? 2'b10 : 2'b00;
                
                if (axi_if.rready) begin
                    next_read_state = R_IDLE;
                end
            end
        endcase
    end

    // Latch read address
    always_ff @(posedge clk) begin : latch_ar_signals
        if (read_state == R_IDLE && axi_if.arvalid && axi_if.arready) begin
            araddr_latched <= axi_if.araddr;
        end
    end

    // Read data output
    assign axi_if.rdata = (addr_valid_read) ? register_bank[read_addr_index] : 32'h0;

endmodule
module axi4_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.slave  axi_if        // AXI-Lite slave interface
);

    // Register bank: 16 registers, each 32-bit
    logic [31:0] register_bank [0:15];

    // Decode logic for write and read addresses
    logic [3:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read; 
    
    // Write and read FSM states
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;
    
    write_state_t write_state, write_next_state;
    read_state_t  read_state, read_next_state;

    // ---------------- WRITE FSM ----------------
    // Update write state every clock
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_state <= W_IDLE; // Reset to idle
        else
            write_state <= write_next_state;
    end

    // Determine next write state
    always_comb begin
        unique case (write_state)
            W_IDLE:  write_next_state = (axi_if.awvalid) ? W_ADDR : W_IDLE; // wait for address
            W_ADDR:  write_next_state = (axi_if.wvalid)  ? W_DATA : W_ADDR; // wait for data
            W_DATA:  write_next_state = W_RESP;  // move to response state
            W_RESP:  write_next_state = (axi_if.bready) ? W_IDLE : W_RESP; // wait for master ready
            default: write_next_state = W_IDLE;
        endcase
    end

    // Generate write channel handshake signals
    always_comb begin
        axi_if.awready = 1'b0;
        axi_if.wready  = 1'b0;
        axi_if.bvalid  = 1'b0;
        axi_if.bresp   = 2'b00; // default OKAY

        unique case(write_state)
            W_IDLE:  if (axi_if.awvalid) axi_if.awready = 1'b1; // ready to accept address
            W_ADDR:  if (axi_if.wvalid)  axi_if.wready  = 1'b1; // ready to accept data
            W_RESP:  begin
                        axi_if.bvalid = 1'b1;                       // response valid
                        axi_if.bresp  = (addr_valid_write) ? 2'b00 : 2'b10; // OKAY or SLVERR
                     end
        endcase
    end  

    // ---------------- READ FSM ----------------
    logic [3:0] latched_read_addr; // latch address for read

    // Update read state and latch address
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_read_addr <= '0;
            read_state        <= R_IDLE;
        end else begin
            read_state <= read_next_state;
            if (axi_if.arvalid && axi_if.arready)
                latched_read_addr <= axi_if.araddr[3:0]; // latch lower 4 bits
        end
    end

    // Determine next read state
    always_comb begin
        read_next_state = read_state;
        unique case (read_state)
            R_IDLE:  if (axi_if.arvalid) read_next_state = R_ADDR; // wait for address
            R_ADDR:  if (axi_if.rready)  read_next_state = R_DATA; // master ready
            R_DATA:  read_next_state = R_IDLE;                     // go back to idle
            default: read_next_state = R_IDLE;
        endcase
    end

    // Generate read channel handshake signals
    always_comb begin
        axi_if.arready = 1'b0;
        axi_if.rvalid  = 1'b0;
        axi_if.rresp   = 2'b00; // default OKAY

        unique case (read_state)
            R_IDLE:  axi_if.arready = 1'b0; // nothing yet
            R_ADDR:  axi_if.arready = 1'b1; // ready to accept address
            R_DATA:  begin
                        axi_if.rvalid = 1'b1; // data valid
                        axi_if.rresp  = 2'b00; // OKAY response
                     end
        endcase
    end

    // ---------------- ADDRESS DECODE ----------------
    assign write_en = (write_state == W_DATA); // write enable pulse
    assign read_en  = (read_state  == R_ADDR); // read enable pulse
    assign read_addr_index = axi_if.araddr[3:0]; // 0..15 registers

    // Decode valid write addresses
    always_comb begin
        addr_valid_write = 1'b0;
        case (axi_if.awaddr)
            32'h00,32'h04,32'h08,32'h0C,32'h10,32'h14,32'h18,32'h1C,
            32'h20,32'h24,32'h28,32'h2C,32'h30,32'h34,32'h38,32'h3C:
                addr_valid_write = 1'b1;
        endcase
    end

    // Decode valid read addresses
    always_comb begin
        addr_valid_read = 1'b0;
        case (axi_if.araddr)
            32'h00,32'h04,32'h08,32'h0C,32'h10,32'h14,32'h18,32'h1C,
            32'h20,32'h24,32'h28,32'h2C,32'h30,32'h34,32'h38,32'h3C:
                addr_valid_read = 1'b1;
        endcase
    end

    // ---------------- WRITE LOGIC ----------------
    // Latch write address
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_addr_index <= 4'h0;
        else if (axi_if.awvalid && axi_if.awready)
            write_addr_index <= axi_if.awaddr[3:0];
    end

    // Write data into register bank
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < 16; i++)
                register_bank[i] <= 32'h0; // reset all registers
        end else if (addr_valid_write && write_en) begin
            register_bank[write_addr_index] <= axi_if.wdata; // write valid data
        end
    end

    // ---------------- READ LOGIC ----------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            axi_if.rdata <= 32'h0; // reset read data
        else if (read_en && addr_valid_read)
            axi_if.rdata <= register_bank[latched_read_addr]; // valid read
        else
            axi_if.rdata <= 32'hDEAD_BEEF; // invalid address
    end

endmodule


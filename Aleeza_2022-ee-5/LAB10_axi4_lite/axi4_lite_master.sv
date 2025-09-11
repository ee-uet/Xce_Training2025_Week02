module axi4_lite_master (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_write,     // Pulse to start a write transaction
    input  logic        start_read,      // Pulse to start a read transaction
    input  logic [31:0] write_address,   // Address for write
    input  logic [31:0] write_data,      // Data to write
    input  logic [31:0] read_address,    // Address for read
    output logic [31:0] read_data,       // Data read from slave
    output logic        write_done,      // Goes high 1 cycle when write finishes
    output logic        read_done,       // Goes high 1 cycle when read finishes
    
    axi4_lite_if.master axi_if            // AXI-Lite interface signals
);

    // Write state machine states
    typedef enum logic [1:0] {
        W_IDLE,    // Waiting for start_write
        W_ADDR,    // Sending write address
        W_DATA,    // Sending write data
        W_RESP     // Waiting for write response
    } write_state_t;

    // Read state machine states
    typedef enum logic [1:0] {
        R_IDLE,    // Waiting for start_read
        R_ADDR,    // Sending read address
        R_DATA     // Reading data back
    } read_state_t;

    write_state_t write_state, write_next_state;
    read_state_t  read_state, read_next_state;

    // ---------------------- WRITE FSM ----------------------

    // Update write state on each clock
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_state <= W_IDLE;   // Reset state to idle
        else
            write_state <= write_next_state;
    end

    // Determine next write state
    always_comb begin
        write_next_state = write_state; // Default: stay in current state
        unique case (write_state)
            W_IDLE: if (start_write) write_next_state = W_ADDR;
            W_ADDR: if (axi_if.awready) write_next_state = W_DATA; // Address accepted by slave
            W_DATA: if (axi_if.wready) write_next_state = W_RESP;  // Data accepted by slave
            W_RESP: if (axi_if.bvalid) write_next_state = W_IDLE;  // Response received, go idle
        endcase
    end

    // Control signals for write FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.awvalid <= 1'b0;
            axi_if.wvalid  <= 1'b0;
            axi_if.bready  <= 1'b0;
            axi_if.awaddr  <= '0;
            axi_if.wdata   <= '0;
            axi_if.wstrb   <= '0;
        end else begin
            unique case (write_state)
                W_IDLE: begin
                    // Nothing to send yet
                    axi_if.awvalid <= 1'b0;
                    axi_if.wvalid  <= 1'b0;
                    axi_if.bready  <= 1'b0;
                end
                W_ADDR: begin
                    // Drive address and assert valid
                    axi_if.awaddr  <= write_address;
                    axi_if.awvalid <= 1'b1;                  
                end
                W_DATA: begin
                    // Drive data and strobe
                    axi_if.wdata  <= write_data;
                    axi_if.wstrb  <= 4'hF; // full 32-bit write
                    axi_if.wvalid <= 1'b1;
                end 
                W_RESP: begin
                    // Ready to accept write response from slave
                    axi_if.bready <= 1'b1;
                end
            endcase
        end
    end

    // ---------------------- READ FSM ----------------------

    // Update read state and capture data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_state <= R_IDLE;
            read_data  <= '0;
        end else begin
            read_state <= read_next_state;
            if (axi_if.rvalid && axi_if.rready) begin
                read_data <= axi_if.rdata;  // Capture read data when ready
            end
        end
    end

    // Determine next read state
    always_comb begin
        read_next_state = read_state; // Default: stay in current state
        unique case (read_state)
            R_IDLE: if (start_read) read_next_state = R_ADDR;
            R_ADDR: if (axi_if.arready) read_next_state = R_DATA; // Address accepted by slave
            R_DATA: if (axi_if.rvalid && axi_if.rresp) read_next_state = R_IDLE; // Data received, go idle
        endcase
    end

    // Control signals for read FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi_if.arvalid <= 1'b0;
            axi_if.rready  <= 1'b0;
            axi_if.araddr  <= '0;
        end else begin
            unique case (read_state)
                R_IDLE: begin
                    // Nothing to send yet
                    axi_if.arvalid <= 1'b0;
                    axi_if.rready  <= 1'b0;
                end
                R_ADDR: begin
                    // Drive read address and assert valid
                    axi_if.arvalid <= 1'b1;
                    axi_if.araddr  <= read_address;
                end
                R_DATA: begin
                    // Ready to accept data from slave
                    axi_if.rready <= 1'b1;
                end
            endcase
        end
    end

    // Generate write_done pulse for 1 clock cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            write_done <= 0;
        else
            write_done <= (write_state == W_RESP) && (write_next_state == W_IDLE);
    end

    // Generate read_done pulse for 1 clock cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_done <= 0;
        else
            read_done <= (read_state == R_DATA) && (read_next_state == R_IDLE);
    end

endmodule


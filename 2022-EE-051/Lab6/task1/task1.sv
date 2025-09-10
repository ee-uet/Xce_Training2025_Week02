module sram_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire [15:0]  sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n
);

    // FSM states
    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;
    state_t state, next_state;

    logic dq_oe;              // Drive enable for write
    logic [15:0] rd_data_reg; // Latched read data
    logic [15:0] sram_data_out; // internal driver for inout bus

    // SRAM interface
    assign sram_ce_n = 1'b0;          // always enabled
    assign sram_addr = address;
    assign sram_data = sram_data_out; // actual bus driver

    // Bus control 
    always_comb begin
        if (dq_oe == 1'b1) begin
            sram_data_out = write_data;   // write mode
        end else begin
            sram_data_out = 16'hzzzz;     // release bus
        end
    end

    // Control signals (OE, WE)
    always_comb begin
        // defaults
        sram_we_n = 1'b1;
        sram_oe_n = 1'b1;

        if (state == WRITE) begin
            sram_we_n = 1'b0;   // enable write
        end else if (state == READ) begin
            sram_oe_n = 1'b0;   // enable read
        end
    end

    // Sequential logic 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state       <= IDLE;
        read_data   <= '0;
        rd_data_reg <= '0;
    end else begin
        state <= next_state;

        // latch after OE is active
        if (state == READ && sram_oe_n == 1'b0) begin
            rd_data_reg <= sram_data; 
        end

        read_data <= rd_data_reg;
    end
end


    // Next-state logic
    always_comb begin
        next_state = state;
        ready   = 1'b0;
        dq_oe   = 1'b0;

        if (state == IDLE) begin
            ready = 1'b1;
            if (write_req == 1'b1) begin
                next_state = WRITE;
            end else if (read_req == 1'b1) begin
                next_state = READ;
            end
        end else if (state == WRITE) begin
            dq_oe      = 1'b1;   
            next_state = IDLE;
        end else if (state == READ) begin
            next_state = IDLE;   
        end
    end

endmodule

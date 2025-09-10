typedef enum logic [2:0] {
    IDLE  = 3'b000,
    read  = 3'b001,
    write = 3'b010
} state_t;

module sram_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n
);
    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        unique case (current_state)
            IDLE: begin
                if (write_req)      next_state = write;
                else if (read_req)  next_state = read;
            end
            read : next_state = IDLE;
            write: next_state = IDLE;
        endcase
    end

    always_comb begin
        unique case (current_state)
            IDLE: begin
                sram_ce_n = 1'b1;
                sram_oe_n = 1'b1;
                sram_we_n = 1'b1;
                sram_addr = address;
                ready     = 1'b0;
            end
            read: begin
                sram_ce_n = 1'b0;
                sram_oe_n = 1'b0;
                sram_we_n = 1'b1;
                sram_addr = address;
                ready     = 1'b1;
            end
            write: begin
                sram_ce_n = 1'b0;
                sram_oe_n = 1'b1;
                sram_we_n = 1'b0;
                sram_addr = address;
                ready     = 1'b1;
            end
        endcase
    end

    assign sram_data = (current_state == write) ? write_data : 16'hZZZZ;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_data <= '0;
        else if (current_state == read)
            read_data <= sram_data;
    end
endmodule

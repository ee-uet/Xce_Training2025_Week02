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
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n
);

    // State definition
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        READ = 2'b01,
        WRITE = 2'b10
    } state_t;

    // Internal registers
    state_t state, next_state;
    logic [15:0] sram_data_out;
    logic sram_data_dir; // 0 = output, 1 = input
    
    // Bidirectional data bus control
    assign sram_data = (sram_data_dir == 1'b0) ? sram_data_out : 16'bz;
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (read_req) 
                    next_state = READ;
                else if (write_req) 
                    next_state = WRITE;
            end
            READ: begin
                next_state = IDLE; // Single cycle operation
            end
            WRITE: begin
                next_state = IDLE; // Single cycle operation
            end
        endcase
    end
    
    // Output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sram_addr <= 15'b0;
            sram_data_out <= 16'b0;
            sram_ce_n <= 1'b1;
            sram_oe_n <= 1'b1;
            sram_we_n <= 1'b1;
            sram_data_dir <= 1'b1; // Input by default
            read_data <= 16'b0;
            ready <= 1'b0;
        end else begin
            case (next_state)
                IDLE: begin
                    sram_ce_n <= 1'b1;
                    sram_oe_n <= 1'b1;
                    sram_we_n <= 1'b1;
                    sram_data_dir <= 1'b1; // Input
                    ready <= 1'b1;
                end
                READ: begin
                    sram_addr <= address;
                    sram_ce_n <= 1'b0;
                    sram_oe_n <= 1'b0;
                    sram_we_n <= 1'b1;
                    sram_data_dir <= 1'b1; // Input (read from SRAM)
                    ready <= 1'b0;
                end
                WRITE: begin
                    sram_addr <= address;
                    sram_data_out <= write_data;
                    sram_ce_n <= 1'b0;
                    sram_oe_n <= 1'b1;
                    sram_we_n <= 1'b0;
                    sram_data_dir <= 1'b0; // Output (write to SRAM)
                    ready <= 1'b0;
                end
            endcase
            
            // Capture read data at the end of read cycle
            if (state == READ) begin
                read_data <= sram_data;
            end
        end
    end

endmodule
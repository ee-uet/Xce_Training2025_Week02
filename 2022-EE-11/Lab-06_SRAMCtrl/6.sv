module sram_controller (
    input logic clk,
    input logic rst_n,
    input logic read_req,
    input logic write_req,
    input logic [14:0] address,
    input logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic ready,
    
    // SRAM interface
    output logic [14:0] sram_addr,
    inout wire [15:0] sram_data,
    output logic sram_ce_n,
    output logic sram_oe_n,
    output logic sram_we_n
);

typedef enum {
    IDLE,
    READ_ACTIVE,
    WRITE_ACTIVE
} state_t;

state_t curr_state, next_state;

// Internal signals for bidirectional control
logic drive_data;
logic [15:0] data_out;

// State machine sequential logic
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        curr_state <= IDLE;
    end else begin
        curr_state <= next_state;
    end
end

// Address and read data registers
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sram_addr <= 15'b0;
        read_data <= 16'b0;
    end else begin
        // Latch address when starting a new operation
        if ((read_req || write_req) && ready) begin
            sram_addr 	<= address;
            data_out  	<= write_data;	
        end
        
        // Capture read data during read operations
        if (curr_state == READ_ACTIVE && !sram_oe_n) begin
            read_data <= sram_data;
        end
    end
end

// Bidirectional data bus control
assign sram_data = drive_data ? data_out : 16'bz;

// State machine combinational logic
always_comb begin
    // Default values
    next_state = curr_state;
    ready = 1'b0;
    sram_ce_n = 1'b1;  // Chip disabled by default
    sram_oe_n = 1'b1;  // Output disabled by default
    sram_we_n = 1'b1;  // Write disabled by default
    drive_data = 1'b0;
    
    case (curr_state)
        IDLE: begin
            ready = 1'b1;
            sram_ce_n = 1'b0;  // Enable chip
            sram_oe_n = 1'b0;  // Enable output
            sram_we_n = 1'b1;  // Disable write
            
            // Start new operations
            if (read_req & (~write_req)) begin
                next_state = READ_ACTIVE;
            end else if (write_req & (~read_req)) begin
                next_state = WRITE_ACTIVE;
            end
            // If both or neither are asserted, stay in IDLE
        end
        
        READ_ACTIVE: begin
            sram_ce_n = 1'b0;  // Enable chip
            sram_oe_n = 1'b0;  // Enable output
            sram_we_n = 1'b1;  // Disable write
            
            // Return to idle after one cycle
            next_state = IDLE;
        end
        
        WRITE_ACTIVE: begin
            sram_ce_n = 1'b0;  // Enable chip
            sram_oe_n = 1'b1;  // Disable output
            sram_we_n = 1'b0;  // Enable write
            drive_data = 1'b1; // Drive data bus
            
            // Return to idle after one cycle
            next_state = IDLE;
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule

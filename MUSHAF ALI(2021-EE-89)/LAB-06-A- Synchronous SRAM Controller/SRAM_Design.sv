
module sram_controller (
    input  logic        clk,
    input  logic        rst,

    // CPU interface
    input  logic        read_req,
    input  logic        write_req,
    input  logic [15:0] data_cpu,
    input  logic [14:0] addr_cpu,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        oe,
    output logic        dq_oe,
    output logic        we,
    output logic        ce
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE, ADDRESS_SETUP, ACCESS_WAIT, CAPTURE_HOLD
    } state_t;
    state_t current_state, next_state;

    // Internal signals
    logic latched_read_req;
    logic latched_write_req;
    logic [2:0] wait_counter;   // simple fixed wait counter

    // Tri-state bus
    assign sram_data = (dq_oe) ? data_cpu  : 16'hzzzz;

    // Sequential logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state      <= IDLE;
            latched_read_req   <= 0;
            latched_write_req  <= 0;
            sram_addr          <= 0;
            read_data          <= 0;
            wait_counter       <= 0;
        end else begin
            current_state <= next_state;

            // latch request only in IDLE
            if (current_state == IDLE && (read_req || write_req)) begin
                latched_read_req  <= read_req;
                latched_write_req <= write_req;
                    sram_addr <= addr_cpu;
            end
            
            //if we done with read and write put lached requests to 0 for next request
            if(current_state==CAPTURE_HOLD) begin
            latched_read_req<=0;
            latched_write_req<=0;
            end
            
            // capture read data
            if (current_state == CAPTURE_HOLD)
                read_data <= sram_data;

            // wait counter for access timing
            if (current_state == ACCESS_WAIT)
                wait_counter <= wait_counter + 1;
            else
                wait_counter <= 0;
        end
    end

    // Combinational logic
    always_comb begin
        // Default outputs
        next_state = current_state;
        ce    = 1;   // disable
        oe    = 1;
        we    = 1;
        dq_oe = 0;
        ready = 0;

        case (current_state)
            IDLE: begin
                ready = 1;
                if (latched_read_req || latched_write_req)
                    next_state = ADDRESS_SETUP;
            end

            ADDRESS_SETUP: begin
                ce = 0;  // enable chip
                next_state = ACCESS_WAIT;
            end

            ACCESS_WAIT: begin
                ce =0;
                if (wait_counter == 3) begin   // simulate access delay
                    if (latched_read_req) begin
                        oe = 0;
                        dq_oe = 0; // float bus for SRAM -> CPU
                        we = 1;
                    end else if (latched_write_req) begin
                        we = 0;
                        dq_oe = 1; // drive CPU -> SRAM
                        oe = 1;
                    end
                    next_state = CAPTURE_HOLD;
                end
            end

            CAPTURE_HOLD: begin
                ce = 0;
                if (latched_read_req) begin
                    oe = 0;
                    dq_oe = 0;
                    we = 1;
                end else if (latched_write_req) begin
                    we = 0;
                    dq_oe = 1;
                    oe = 1;
                end
                next_state = IDLE;
            end
        endcase
    end

endmodule
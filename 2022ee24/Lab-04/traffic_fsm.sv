/*
                          +----------------+
                          |    S5          |
                          | STARTUP_FLASH  |
                          |  (5s flashing) |
                          +----------------+
                                |
            emerg==11 ----------+-------> S4 (IMMEDIATE emergency)
                                |
                                v
                          +----------------+
                          |    S0          |
                          | NS_GREEN       |
                          | EW_RED         |
                          +----------------+
                                |
        emerg==11 --------------+-------> S4
        green_count==15 && ped  +-------> S1 (short green)
        green_count==30 --------+-------> S1 (full green)
                                |
                                v
                          +----------------+
                          |    S1          |
                          | NS_YELLOW      |
                          | EW_RED         |
                          +----------------+
                                |
        emerg==11 --------------+-------> S4
        SAFE emergency (at end) +-------> S4
        ped_request (at end) ---+-------> S6
        else (end of yellow) ---+-------> S2
                                |
                                v
                          +----------------+
                          |    S2          |
                          | NS_RED         |
                          | EW_GREEN       |
                          +----------------+
                                |
        emerg==11 --------------+-------> S4
        green_count==15 && ped  +-------> S3
        green_count==30 --------+-------> S3
                                |
                                v
                          +----------------+
                          |    S3          |
                          | NS_RED         |
                          | EW_YELLOW      |
                          +----------------+
                                |
        emerg==11 --------------+-------> S4
        SAFE emergency (at end) +-------> S4
        ped_request (at end) ---+-------> S6
        else (end of yellow) ---+-------> S0
                                |
                                v
                          +----------------+
                          |    S6          |
                          | PEDESTRIAN     |
                          | CROSSING       |
                          | (max 15s)      |
                          +----------------+
                                |
        emerg==11 --------------+-------> S4
        ped_request==0 ---------+-------> S0 (exit early)
        T_ped==15 --------------+-------> S0 (timeout)
        SAFE emergency (at end) +-------> S4
                                |
                                v
                          +----------------+
                          |    S4          |
                          | EMERGENCY_ALL  |
                          | RED (flashing) |
                          +----------------+
                                |
        emerg != 00 ------------+-------> stay S4
        emerg == 00 ------------+-------> S0 (restart cycle)
*/


typedef enum logic [1:0] {
    RED     = 2'b00,
    YELLOW  = 2'b01,
    GREEN   = 2'b10,
    FLASH   = 2'b11   // flashing mode
} lights_t;

module traffic_fsm (
    input  logic       clk,
    input  logic       reset_n,
    input  logic [1:0] emerg_async,   // 00=none, 01/10=safe, 11=immediate
    input  logic       ped_request_async,
    output lights_t    ns_light,
    output lights_t    ew_light,
    output logic       ped_walk,
    output logic       flash_enable
);


    
    // FSM states
    typedef enum logic [2:0] {
        S5_STARTUP   = 3'd0,
        S0_NS_GREEN  = 3'd1,
        S1_NS_YELLOW = 3'd2,
        S2_EW_GREEN  = 3'd3,
        S3_EW_YELLOW = 3'd4,
        S6_PED       = 3'd5,
        S4_EMERG     = 3'd6
    } state_t;

    state_t state, next_state;

    
    // Synchronizers for async inputs
    
    logic [1:0] emerg_ff1, emerg_ff2;
    logic ped_ff1, ped_ff2;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            emerg_ff1 <= 2'b00;
            emerg_ff2 <= 2'b00;
            ped_ff1   <= 1'b0;
            ped_ff2   <= 1'b0;
        end else begin
            emerg_ff1 <= emerg_async;
            emerg_ff2 <= emerg_ff1;
            ped_ff1   <= ped_request_async;
            ped_ff2   <= ped_ff1;
        end
    end
    wire [1:0] emerg       = emerg_ff2;
    wire       ped_request = ped_ff2;

    
    // Counters
    
    logic [5:0] sec_counter;  // up to 60
    logic [3:0] ped_counter;  // up to 15

    
    // Sequential state + counters
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state       <= S5_STARTUP;
            sec_counter <= 0;
            ped_counter <= 0;
        end else begin
            state <= next_state;

            // counter logic
            unique case (state)
                S5_STARTUP:   sec_counter <= (next_state != state) ? 0 : sec_counter + 1;
                S0_NS_GREEN,
                S2_EW_GREEN:  sec_counter <= (next_state != state) ? 0 : sec_counter + 1;
                S1_NS_YELLOW,
                S3_EW_YELLOW: sec_counter <= (next_state != state) ? 0 : sec_counter + 1;
                S6_PED: begin
                    sec_counter <= 0;
                    ped_counter <= (next_state != state) ? 0 : ped_counter + 1;
                end
                default: begin
                    sec_counter <= 0;
                    ped_counter <= 0;
                end
            endcase
        end
    end

    
    // Next-state logic
    always_comb begin
        next_state = state;
        unique case (state)

            
            // S5 STARTUP
            S5_STARTUP: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (sec_counter >= 5)         next_state = S0_NS_GREEN;
            end

            
            // S0 NS_GREEN
            S0_NS_GREEN: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (sec_counter == 15 && ped_request)
                                                    next_state = S1_NS_YELLOW;
                else if (sec_counter >= 30)        next_state = S1_NS_YELLOW;
            end

            
            // S1 NS_YELLOW  
            S1_NS_YELLOW: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (sec_counter >= 5) begin
                    if (emerg == 2'b01 || emerg == 2'b10)
                                                    next_state = S4_EMERG;   // safe honored here
                    else if (ped_request)          next_state = S6_PED;
                    else                           next_state = S2_EW_GREEN;
                end
            end

            
            // S2 EW_GREEN  
            S2_EW_GREEN: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (sec_counter == 15 && ped_request)
                                                    next_state = S3_EW_YELLOW;
                else if (sec_counter >= 30)        next_state = S3_EW_YELLOW;
            end

            
            // S3 EW_YELLOW  
            S3_EW_YELLOW: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (sec_counter >= 5) begin
                    if (emerg == 2'b01 || emerg == 2'b10)
                                                    next_state = S4_EMERG;
                    else if (ped_request)          next_state = S6_PED;
                    else                           next_state = S0_NS_GREEN;
                end
            end

            
            // S6 PEDESTRIAN
            S6_PED: begin
                if (emerg == 2'b11)                next_state = S4_EMERG;
                else if (!ped_request)             next_state = S0_NS_GREEN;
                else if (ped_counter >= 15) begin
                    if (emerg == 2'b01 || emerg == 2'b10)
                                                    next_state = S4_EMERG;   // safe honored only at expiry
                    else                           next_state = S0_NS_GREEN;
                end
            end

            
            // S4 EMERGENCY
            S4_EMERG: begin
                if (emerg == 2'b00)                next_state = S0_NS_GREEN;
                else                               next_state = S4_EMERG;
            end
        endcase
    end

    
    // Output logic
    always_comb begin
        ns_light    = RED;
        ew_light    = RED;
        ped_walk    = 1'b0;
        flash_enable= 1'b0;

        unique case (state)
            S5_STARTUP: begin
                ns_light    = FLASH;
                ew_light    = FLASH;
                flash_enable= 1'b1;
            end
            S0_NS_GREEN: begin
                ns_light = GREEN;
                ew_light = RED;
            end
            S1_NS_YELLOW: begin
                ns_light = YELLOW;
                ew_light = RED;
            end
            S2_EW_GREEN: begin
                ns_light = RED;
                ew_light = GREEN;
            end
            S3_EW_YELLOW: begin
                ns_light = RED;
                ew_light = YELLOW;
            end
            S6_PED: begin
                ns_light = RED;
                ew_light = RED;
                ped_walk = 1'b1;
            end
            S4_EMERG: begin
                ns_light    = FLASH;
                ew_light    = FLASH;
                flash_enable= 1'b1;
            end
        endcase
    end

endmodule

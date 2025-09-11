module traffic_controller (
    input  logic       clk,               
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [1:0] ns_lights,        // Encoded: [Red, Yellow, Green]
    output logic [1:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);

    // Light encodings (2 bits for 3 states)
    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;
    localparam OFF    = 2'b11;

    // FSM states
    typedef enum logic [2:0] {
        STARTUP_FLASH,
        NS_GREEN_EW_RED,
        NS_YELLOW_EW_RED,
        NS_RED_EW_GREEN,
        NS_RED_EW_YELLOW,
        PEDESTRIAN_CROSSING,
        EMERGENCY_ALL_RED
    } state_t;

    state_t state, next_state;
    state_t return_state, next_return_state; // Register to remember where to return

    // Timer
    logic [5:0] timer_count;
    logic       timer_reset;

    timer u_timer (
        .clk   (clk),
        .rst_n (rst_n),
        .start (timer_reset),
        .count (timer_count)
    );

    // Pedestrian latch
    logic ped_latch;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ped_latch <= 1'b0;
        else if (pedestrian_req)
            ped_latch <= 1'b1;
        else if (state == PEDESTRIAN_CROSSING) // Clear latch after service starts
            ped_latch <= 1'b0;
    end

    // FSM state registers (main state and return state)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= STARTUP_FLASH;
            return_state <= NS_GREEN_EW_RED; // Default return state
        end else begin
            state        <= next_state;
            return_state <= next_return_state;
        end
    end

    // FSM combinational logic
    always_comb begin
        // Defaults
        next_state        = state;
        next_return_state = return_state; // By default, don't change the return state
        timer_reset       = 1'b0;
        ns_lights         = RED;
        ew_lights         = RED;
        ped_walk          = 1'b0;
        emergency_active  = 1'b0;

        case (state)
            STARTUP_FLASH: begin
                ns_lights = (timer_count[0]) ? RED : OFF;
                ew_lights = (timer_count[0]) ? RED : OFF;
                if (timer_count >= 5) begin
                    next_state  = NS_GREEN_EW_RED;
                    timer_reset = 1'b1;
                end
            end

            NS_GREEN_EW_RED: begin
                ns_lights = GREEN;
                ew_lights = RED;
                if (emergency) begin
                    next_state  = EMERGENCY_ALL_RED;
                    timer_reset = 1'b1;
                end else if (timer_count >= 30) begin
                    // A green light MUST be followed by a yellow light.
                    next_state  = NS_YELLOW_EW_RED;
                    timer_reset = 1'b1;
                end
            end

            NS_YELLOW_EW_RED: begin
                ns_lights = YELLOW;
                ew_lights = RED;
                if (emergency) begin
                    next_state  = EMERGENCY_ALL_RED;
                    timer_reset = 1'b1;
                end else if (timer_count >= 5) begin
                    if (ped_latch) begin
                        next_state        = PEDESTRIAN_CROSSING;
                        // Save the state that should come AFTER this cycle
                        next_return_state = NS_RED_EW_GREEN;
                    end else begin
                        next_state        = NS_RED_EW_GREEN;
                    end
                    timer_reset = 1'b1;
                end
            end

            NS_RED_EW_GREEN: begin
                ns_lights = RED;
                ew_lights = GREEN;
                if (emergency) begin
                    next_state  = EMERGENCY_ALL_RED;
                    timer_reset = 1'b1;
                end else if (timer_count >= 30) begin
                    next_state  = NS_RED_EW_YELLOW;
                    timer_reset = 1'b1;
                end
            end

            NS_RED_EW_YELLOW: begin
                ns_lights = RED;
                ew_lights = YELLOW;
                if (emergency) begin
                    next_state  = EMERGENCY_ALL_RED;
                    timer_reset = 1'b1;
                end else if (timer_count >= 5) begin
                    if (ped_latch) begin
                        next_state        = PEDESTRIAN_CROSSING;
                        // Save the state that should come AFTER this cycle
                        next_return_state = NS_GREEN_EW_RED;
                    end else begin
                        next_state        = NS_GREEN_EW_RED;
                    end
                    timer_reset = 1'b1;
                end
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights = RED;
                ew_lights = RED;
                ped_walk  = 1'b1;
                if (emergency) begin
                    next_state  = EMERGENCY_ALL_RED;
                    timer_reset = 1'b1;
                end else if (timer_count >= 10) begin
                    // Go to the saved return state for a fair cycle
                    next_state  = return_state;
                    timer_reset = 1'b1;
                end
            end

            EMERGENCY_ALL_RED: begin
                ns_lights = (timer_count[0]) ? RED : OFF;
                ew_lights = (timer_count[0]) ? RED : OFF;
                emergency_active = 1'b1;
                if (!emergency) begin
                    next_state  = STARTUP_FLASH;
                    timer_reset = 1'b1;
                end
            end
        endcase
    end
endmodule
module traffic_controller (
    input  logic       clk,           // 1 Hz clock signal (ticks once per second)
    input  logic       rst_n,         // Active-low reset
    input  logic       emergency,     // Emergency mode request
    input  logic       pedestrian_req,// Pedestrian crossing request
    output logic [2:0] ns_lights,     // North–South lights: [Red, Yellow, Green]
    output logic [2:0] ew_lights,     // East–West lights: [Red, Yellow, Green]
    output logic       ped_walk,      // Pedestrian walk signal
    output logic       emergency_active // Shows emergency mode is active
);

    // Different traffic light states
    typedef enum logic [2:0] {
        NS_GREEN_EW_RED     = 3'b000, // North-South green, East-West red
        NS_YELLOW_EW_RED    = 3'b001, // North-South yellow, East-West red
        NS_RED_EW_GREEN     = 3'b010, // North-South red, East-West green
        NS_RED_EW_YELLOW    = 3'b011, // North-South red, East-West yellow
        PEDESTRIAN_CROSSING = 3'b100, // All vehicle lights red, pedestrian walk on
        EMERGENCY_ALL_RED   = 3'b101  // All red lights (emergency)
    } state_t;

    state_t current_state, next_state;

    // Timer counts down seconds for each state
    logic [5:0] timer;       // 6-bit timer to hold seconds
    logic       timer_done;  // Goes high when timer reaches zero

    // Timer done when it hits zero
    assign timer_done = (timer == 0);

    // Current state register (state update on clock edge)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= NS_GREEN_EW_RED; // Start in NS green on reset
        else
            current_state <= next_state;      // Otherwise go to next state
    end

    // Timer logic: load new time when state changes, otherwise count down
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= 0;
        end 
        else if (current_state != next_state) begin
            // Load timer depending on the new state
            case (next_state)
                NS_GREEN_EW_RED:     timer <= 30; // 30 seconds green
                NS_YELLOW_EW_RED:    timer <= 5;  // 5 seconds yellow
                NS_RED_EW_GREEN:     timer <= 30; // 30 seconds green
                NS_RED_EW_YELLOW:    timer <= 5;  // 5 seconds yellow
                PEDESTRIAN_CROSSING: timer <= 10; // 10 seconds walk
                EMERGENCY_ALL_RED:   timer <= 2;  // 2 seconds all red in emergency
                default:             timer <= 0;
            endcase
        end 
        else if (timer > 0) begin
            timer <= timer - 1; // Count down by 1 second
        end
    end

    // Next-state logic based on current state, timer, and inputs
    always_comb begin
        next_state = current_state; // Default: stay in same state

        case (current_state)
            NS_GREEN_EW_RED: begin
                if (emergency)         next_state = EMERGENCY_ALL_RED; // Emergency overrides
                else if (timer_done)   next_state = NS_YELLOW_EW_RED;  // Move to yellow
            end

            NS_YELLOW_EW_RED: begin
                if (emergency)         next_state = EMERGENCY_ALL_RED;
                else if (timer_done)   next_state = NS_RED_EW_GREEN;   // Switch direction
            end

            NS_RED_EW_GREEN: begin
                if (emergency)         next_state = EMERGENCY_ALL_RED;
                else if (timer_done)   next_state = NS_RED_EW_YELLOW;  // Move to yellow
            end

            NS_RED_EW_YELLOW: begin
                if (emergency)         next_state = EMERGENCY_ALL_RED;
                else if (timer_done) begin
                    // After yellow, check for pedestrians
                    if (pedestrian_req) next_state = PEDESTRIAN_CROSSING;
                    else                next_state = NS_GREEN_EW_RED; // Back to NS green
                end
            end

            PEDESTRIAN_CROSSING: begin
                if (emergency)         next_state = EMERGENCY_ALL_RED;
                else if (timer_done)   next_state = NS_GREEN_EW_RED;   // Resume normal cycle
            end

            EMERGENCY_ALL_RED: begin
                // Stay all red until emergency clears
                if (!emergency)        next_state = NS_GREEN_EW_RED;
            end

            default: next_state = NS_GREEN_EW_RED;
        endcase
    end

    // Output logic: decide which lights and signals are active
    always_comb begin
        // Default: all red, no pedestrian walk, no emergency
        ns_lights        = 3'b100; // Red
        ew_lights        = 3'b100; // Red
        ped_walk         = 0;
        emergency_active = 0;

        case (current_state)
            NS_GREEN_EW_RED:     begin ns_lights = 3'b001; ew_lights = 3'b100; end // NS green, EW red
            NS_YELLOW_EW_RED:    begin ns_lights = 3'b010; ew_lights = 3'b100; end // NS yellow, EW red
            NS_RED_EW_GREEN:     begin ns_lights = 3'b100; ew_lights = 3'b001; end // NS red, EW green
            NS_RED_EW_YELLOW:    begin ns_lights = 3'b100; ew_lights = 3'b010; end // NS red, EW yellow
            PEDESTRIAN_CROSSING: begin ns_lights = 3'b100; ew_lights = 3'b100; ped_walk = 1; end // All red + walk
            EMERGENCY_ALL_RED:   begin ns_lights = 3'b100; ew_lights = 3'b100; emergency_active = 1; end // All red + emergency
        endcase
    end

endmodule


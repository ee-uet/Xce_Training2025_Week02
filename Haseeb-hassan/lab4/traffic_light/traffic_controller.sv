typedef enum logic [2:0] {
    STARTUP_FLASH      = 3'b000,
    NS_GREEN_EW_RED    = 3'b001,
    NS_YELLOW_EW_RED   = 3'b010,
    NS_RED_EW_GREEN    = 3'b011,
    NS_RED_EW_YELLOW   = 3'b100,
    EMERGENCY_ALL_RED  = 3'b101,
    PEDESTRIAN_CROSSING= 3'b110
} state_t;

module traffic_controller(
    input  logic       clk,           // 1 Hz clock
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [1:0] ns_lights,     // 2-bit code: RED, YELLOW, GREEN
    output logic [1:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);
    state_t    current_state, next_state;
    state_t    prev_state;

    // timer control
    logic       timer_start;     // 1-cycle pulse to timer
    logic [7:0] timer_load;
    logic       timer_done;

    // request latches
    logic       ped_pending;

    // instantiate pulse-based timer from above
    timer timer_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (timer_start),
        .load_value(timer_load),
        .done      (timer_done)
    );

    // light encodings
    localparam logic [1:0] RED    = 2'b00;
    localparam logic [1:0] YELLOW = 2'b01;
    localparam logic [1:0] GREEN  = 2'b10;

    // state register & previous state (for entry detection)
    // state register & previous state (for entry detection)
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STARTUP_FLASH;
        prev_state    <= STARTUP_FLASH;
        ped_pending   <= 1'b0;
    end
    else begin
        prev_state    <= current_state;
        current_state <= next_state;
        // latch pedestrian request (edge or level)
        if (pedestrian_req) begin
            ped_pending <= 1'b1;
        end
        // clear ped_pending when we finish the crossing
        if ((current_state == PEDESTRIAN_CROSSING) && (timer_done)) begin
            ped_pending <= 1'b0;
        end
        // ped_pending cleared when we finish the crossing (below)
        // emergency is handled combinationally (priority)
    end
end
    // detect state entry (prev_state updated on same clock, so use prev_state from previous cycle)
    logic state_entry;
    always_comb state_entry = (current_state != prev_state);

    // Next-state logic (combinational)
    always_comb begin
        next_state  = current_state;
        timer_start = 1'b0;
        timer_load  = 8'd0;

        // Emergency overrides everything (highest priority)
        if (emergency) begin
            next_state = EMERGENCY_ALL_RED;
        end else begin
            case (current_state)
                STARTUP_FLASH: begin
                    // start timer on entry to flash (you can handle blinking by toggling an output using timer_done)
                    if (state_entry) begin
                        timer_load  = 8'd5;
                        timer_start = 1'b1;
                    end
                    // when timer done -> normal operation
                    if (timer_done)
                        next_state = NS_GREEN_EW_RED;
                end

                NS_GREEN_EW_RED: begin
                    if (state_entry) begin
                        timer_load  = 8'd30;
                        timer_start = 1'b1;
                    end
                    if (timer_done) begin
                        next_state = NS_YELLOW_EW_RED;
                    end
                end

                NS_YELLOW_EW_RED: begin
                    if (state_entry) begin
                        timer_load  = 8'd5;
                        timer_start = 1'b1;
                    end
                    if (timer_done) begin
                        // if a pedestrian is pending, go to pedestrian crossing (safe point after yellow)
                        if (ped_pending)
                            next_state = PEDESTRIAN_CROSSING;
                        else
                            next_state = NS_RED_EW_GREEN;
                    end
                end

                NS_RED_EW_GREEN: begin
                    if (state_entry) begin
                        timer_load  = 8'd30;
                        timer_start = 1'b1;
                    end
                    if (timer_done) begin
                        next_state = NS_RED_EW_YELLOW;
                    end
                end

                NS_RED_EW_YELLOW: begin
                    if (state_entry) begin
                        timer_load  = 8'd5;
                        timer_start = 1'b1;
                    end
                    if (timer_done) begin
                        // after EW yellow, go to NS green
                        if (ped_pending)
                            next_state = PEDESTRIAN_CROSSING;
                        else
                            next_state = NS_GREEN_EW_RED;
                    end
                end

                PEDESTRIAN_CROSSING: begin
                    // on entry, start the pedestrian crossing timer (e.g., 10s)
                    if (state_entry) begin
                        timer_load  = 8'd10; // pedestrian crossing time (seconds)
                        timer_start = 1'b1;
                    end
                    // while pedestrian crossing, lights are all red and ped_walk is 1
                    if (timer_done) begin
                        // crossing served: clear pending and return to startup or next cycle
                        next_state = STARTUP_FLASH;   // or choose a specific next state to resume normal flow
                    end
                end

                EMERGENCY_ALL_RED: begin
                    // In emergency state we keep all red. Once emergency is cleared, return to startup.
                    if (!emergency) begin
                        next_state = STARTUP_FLASH;
                    end
                end

                default: next_state = STARTUP_FLASH;
            endcase
        end
    end

    // outputs (combinational)
    always_comb begin
        // defaults
        ns_lights        = RED;
        ew_lights        = RED;
        ped_walk         = 1'b0;
        emergency_active = 1'b0;

        case (current_state)
            STARTUP_FLASH: begin
                // simple startup: both red (you can implement blinking using timer_done toggling)
                ns_lights = RED;
                ew_lights = RED;
            end

            NS_GREEN_EW_RED: begin
                ns_lights = GREEN;
                ew_lights = RED;
            end

            NS_YELLOW_EW_RED: begin
                ns_lights = YELLOW;
                ew_lights = RED;
            end

            NS_RED_EW_GREEN: begin
                ns_lights = RED;
                ew_lights = GREEN;
            end

            NS_RED_EW_YELLOW: begin
                ns_lights = RED;
                ew_lights = YELLOW;
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights = RED;
                ew_lights = RED;
                ped_walk  = 1'b1;
            end

            EMERGENCY_ALL_RED: begin
                ns_lights        = RED;
                ew_lights        = RED;
                emergency_active = 1'b1;
            end

            default: begin
                ns_lights = RED;
                ew_lights = RED;
            end
        endcase
    end


endmodule

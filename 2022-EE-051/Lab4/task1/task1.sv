typedef enum logic [2:0] {
    RESET               = 3'b000,
    STARTUP_FLASH       = 3'b001,
    NS_GREEN_EW_RED     = 3'b010,
    NS_YELLOW_EW_RED    = 3'b011,
    NS_RED_EW_YELLOW     = 3'b100,
    NS_RED_EW_GREEN    = 3'b101,
    EMERGENCY_ALL_RED   = 3'b110,
    PEDESTRIAN_CROSSING = 3'b111
} state_t;

module traffic_controller (
    input  logic clk,             // 1 Hz clock
    input  logic rst_n,
    input  logic emergency,
    input  logic pedestrian_req,
    output logic [1:0] ns_lights, // {Red,Yellow,Green}
    output logic [1:0] ew_lights,
    output logic ped_walk,
    output logic emergency_active
);

    state_t state, next_state, prev_state; 

    // timer counter
    logic [5:0] timer; 
    logic       timer_done;

    // duration for each state
    localparam int GREEN_TIME  = 30;
    localparam int YELLOW_TIME = 5;

    // sequential
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RESET;
            timer <= 0;
        end
        else begin
            if (timer_done) begin
                state <= next_state;
                timer <= 0; // reset timer for next state
                if (state == NS_GREEN_EW_RED || state == NS_YELLOW_EW_RED ||
                    state == NS_RED_EW_GREEN || state == NS_RED_EW_YELLOW) begin
                    prev_state <= state;
                end
            end
            else begin
                state <= state;
                timer <= timer + 1; 
            end
        end
    end

    // check timer expiry per state
    always_comb begin
        timer_done = 1'b0;
        case (state)
            STARTUP_FLASH:       if (timer >= YELLOW_TIME)  timer_done = 1;
            NS_GREEN_EW_RED:     if (timer >= GREEN_TIME)  timer_done = 1;
            NS_YELLOW_EW_RED:    if (timer >= YELLOW_TIME) timer_done = 1;
            NS_RED_EW_YELLOW:    if (timer >= YELLOW_TIME) timer_done = 1; 
            NS_RED_EW_GREEN:     if (timer >= GREEN_TIME)  timer_done = 1; 
            PEDESTRIAN_CROSSING: if (timer >= GREEN_TIME || !pedestrian_req) timer_done = 1;
            EMERGENCY_ALL_RED:   if (timer >= GREEN_TIME || !emergency) timer_done = 1; 
            default:             timer_done = 1;
        endcase
    end

    // combinational: next state logic
    always_comb begin
        next_state = state;
        unique case (state)
            RESET: begin
                next_state = STARTUP_FLASH;
            end

            STARTUP_FLASH: begin
                next_state = NS_GREEN_EW_RED;
            end

            NS_GREEN_EW_RED: begin
                if (emergency)
                    next_state = EMERGENCY_ALL_RED;
                else if (pedestrian_req)
                    next_state = PEDESTRIAN_CROSSING;
                else
                    next_state = NS_YELLOW_EW_RED;
            end

            NS_YELLOW_EW_RED: begin
                 if (emergency)
                     next_state = EMERGENCY_ALL_RED;
                 else if (pedestrian_req)
                     next_state = PEDESTRIAN_CROSSING;
                 else
                     next_state = NS_RED_EW_YELLOW;
            end

            NS_RED_EW_YELLOW: begin
                if (emergency)
                    next_state = EMERGENCY_ALL_RED;
                else if (pedestrian_req)
                    next_state = PEDESTRIAN_CROSSING;
                else
                    next_state = NS_GREEN_EW_RED;
            end

            NS_RED_EW_GREEN: begin
                if (emergency)
                    next_state = EMERGENCY_ALL_RED;
                else if (pedestrian_req)
                    next_state = PEDESTRIAN_CROSSING;
                else
                    next_state = NS_RED_EW_YELLOW;
            end

            EMERGENCY_ALL_RED: begin
                if (!emergency)
                    next_state = prev_state; // return to previous normal state
            end

            PEDESTRIAN_CROSSING: begin
                next_state = prev_state; // return to previous normal state
            end
        endcase
    end

    // output logic
    always_comb begin
        // defaults
        ns_lights = 2'b00;
        ew_lights = 2'b00;
        ped_walk  = 1'b0;
        emergency_active = 1'b0;

        unique case (state)
            RESET: begin
                ns_lights = 2'b00;
                ew_lights = 2'b00;
            end

            STARTUP_FLASH: begin
                ns_lights = 2'b01; 
                ew_lights = 2'b01;
            end

            NS_GREEN_EW_RED: begin
                ns_lights = 2'b10; // Green
                ew_lights = 2'b00; // Red
            end

            NS_YELLOW_EW_RED: begin
                ns_lights = 2'b01; // Yellow
                ew_lights = 2'b00;
            end

            NS_RED_EW_GREEN: begin
                ns_lights = 2'b00;
                ew_lights = 2'b10;
            end

            NS_RED_EW_YELLOW: begin
                ns_lights = 2'b00;
                ew_lights = 2'b01;
            end

            EMERGENCY_ALL_RED: begin
                ns_lights = 2'b00;
                ew_lights = 2'b00;
                emergency_active = 1'b1;
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights = 2'b00;
                ew_lights = 2'b00;
                ped_walk  = 1'b1;
            end
        endcase
    end

endmodule

module traffic_controller (
    input  logic       clk,            // 1 Hz
    input  logic       rst_n, 
    input  logic       emergency, 
    input  logic       pedestrian_req, 
    output logic [1:0] ns_lights,      // 00=Red, 01=Green, 10=Yellow
    output logic [1:0] ew_lights,
    output logic       ped_walk, 
    output logic       emergency_active
);

    // Timer
    int timer_count;
    int duration;

    // States
    typedef enum logic [2:0] {
        STARTUP_FLASH,
        NS_GREEN_EW_RED,
        NS_YELLOW_EW_RED,
        NS_RED_EW_GREEN,
        NS_RED_EW_YELLOW,
        PEDESTRIAN_CROSSING,
        EMERGENCY_ALL_RED
    } state_t;

    state_t current_state, next_state;

    // Timer logic
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            timer_count <= 0;
        else if(current_state != next_state)
            timer_count <= 0;  // reset timer on state change
        else
            timer_count <= timer_count + 1;
    end

    // Set duration for each state
    always_comb begin
        case(current_state)
            STARTUP_FLASH: duration = 2;       // 5s startup flashing
            NS_GREEN_EW_RED: duration = 30;
            NS_YELLOW_EW_RED: duration = 5;
            NS_RED_EW_GREEN: duration = 30;
            NS_RED_EW_YELLOW: duration = 5;
            PEDESTRIAN_CROSSING: duration = 10;
            EMERGENCY_ALL_RED: duration = 1; 
            default: duration = 1;
        endcase
    end

    // Timer done logic
    logic timer_done;
    always_comb begin
         timer_done = (timer_count >= duration);
    end

    // FSM - next state logic
    always_comb begin
        next_state = current_state;

        // Emergency overrides all
        if(emergency)
            next_state = EMERGENCY_ALL_RED;
        else begin
            case(current_state)
                STARTUP_FLASH: 
                    if(timer_done) next_state = NS_GREEN_EW_RED;

                NS_GREEN_EW_RED: 
                    if(timer_done && pedestrian_req) next_state = PEDESTRIAN_CROSSING;
                    else if(timer_done) next_state = NS_YELLOW_EW_RED;

                NS_YELLOW_EW_RED: 
                    if(timer_done) next_state = NS_RED_EW_GREEN;

                NS_RED_EW_GREEN: 
                    if(timer_done && pedestrian_req) next_state = PEDESTRIAN_CROSSING;
                    else if(timer_done) next_state = NS_RED_EW_YELLOW;

                NS_RED_EW_YELLOW: 
                    if(timer_done) next_state = NS_GREEN_EW_RED;

                PEDESTRIAN_CROSSING:
                    if(timer_done) next_state = NS_GREEN_EW_RED;//resume normal

                EMERGENCY_ALL_RED:
                    if(!emergency) next_state = NS_GREEN_EW_RED; // resume normal

                default: next_state = NS_GREEN_EW_RED;
            endcase
        end
    end

    // FSM - state register
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= STARTUP_FLASH;
        else
            current_state <= next_state;
    end

    // Output logic
    always_comb begin
        // Defaults
        ns_lights = 2'b00; // Red
        ew_lights = 2'b00;
        ped_walk = 0;
        emergency_active = 0;

        case(current_state)
            STARTUP_FLASH: begin 
                ns_lights = timer_count[0] ? 2'b01 : 2'b00; // blink NS green
                ew_lights = 2'b00;
            end

            NS_GREEN_EW_RED: begin ns_lights=2'b01; ew_lights=2'b00; end
            NS_YELLOW_EW_RED: begin ns_lights=2'b10; ew_lights=2'b00; end
            NS_RED_EW_GREEN: begin ns_lights=2'b00; ew_lights=2'b01; end
            NS_RED_EW_YELLOW: begin ns_lights=2'b00; ew_lights=2'b10; end
            PEDESTRIAN_CROSSING: begin ns_lights=2'b00; ew_lights=2'b00; ped_walk=1; end
            EMERGENCY_ALL_RED: begin ns_lights=2'b00; ew_lights=2'b00; emergency_active=1; end
        endcase
    end

endmodule

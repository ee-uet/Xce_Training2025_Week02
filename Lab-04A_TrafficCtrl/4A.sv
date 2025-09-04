module traffic_controller (
    input  logic       clk,           // 1 Hz
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [1:0] ns_lights,     // [1:0] format: 00=OFF, 01=GREEN, 10=RED, 11=YELLOW
    output logic [1:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);

    typedef enum logic [2:0] {
        NS_GREEN_EW_RED,
        NS_YELLOW_EW_RED, 
        NS_RED_EW_GREEN,
        NS_RED_EW_YELLOW,
        EMERGENCY_ALL_RED,
        PEDESTRIAN_CROSSING,
        STARTUP_FLASH
    } state_t;
    
    state_t curr_state, next_state;
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_state <= #1 STARTUP_FLASH;
        end else begin
            curr_state <= #1 next_state;
        end
    end

    logic [4:0] counter;
    logic counter_of;
    
    // Counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n || counter_of) begin
            counter <= #1 0;
        end else begin
            counter <= #1 counter + 1;
        end
    end
    
    // Counter overflow logic - different timeouts for different states
    always_comb begin
        case (curr_state)
            STARTUP_FLASH:       counter_of = (counter == 5'd10);  // 10 cycles
            NS_GREEN_EW_RED:     counter_of = (counter == 5'd30);  // 30 cycles
            NS_YELLOW_EW_RED:    counter_of = (counter == 5'd5);   // 5 cycles
            NS_RED_EW_GREEN:     counter_of = (counter == 5'd30);  // 30 cycles
            NS_RED_EW_YELLOW:    counter_of = (counter == 5'd5);   // 5 cycles
            EMERGENCY_ALL_RED:   counter_of = 1'b0;                // No timeout in emergency
            PEDESTRIAN_CROSSING: counter_of = (counter == 5'd15);  // 15 cycles
            default:             counter_of = 1'b0;
        endcase
    end
    
    // FSM logic
    always_comb begin
        // Default outputs
        ped_walk = 0;
        ns_lights = 2'b00;  // OFF
        ew_lights = 2'b00;  // OFF
        emergency_active = 0;
        next_state = curr_state;
        
        case(curr_state)
            STARTUP_FLASH: begin
                // Fixed typo: was {ew, lights, ns_lights}
                {ew_lights, ns_lights} = counter[0] ? 4'b1010 : 4'b0000;
                
                casez({emergency, pedestrian_req, counter_of})
                    3'b1??: next_state = EMERGENCY_ALL_RED;
                    3'b01?: next_state = PEDESTRIAN_CROSSING;
                    3'b001: next_state = NS_GREEN_EW_RED;
                    default: next_state = STARTUP_FLASH;
                endcase
            end
            
            NS_GREEN_EW_RED: begin
                {ew_lights, ns_lights} = 4'b1001;  // EW=RED, NS=GREEN
                if (emergency) 
                    next_state = EMERGENCY_ALL_RED;
                else if (counter_of)
                    next_state = NS_YELLOW_EW_RED;
                else
                    next_state = NS_GREEN_EW_RED;
            end
            
            NS_YELLOW_EW_RED: begin
                {ew_lights, ns_lights} = 4'b1011;  // EW=RED, NS=YELLOW
                casez({counter_of, emergency, pedestrian_req})
                    3'b11?: next_state = EMERGENCY_ALL_RED;
                    3'b101: next_state = PEDESTRIAN_CROSSING;
                    3'b100: next_state = NS_RED_EW_GREEN;
                    default: next_state = NS_YELLOW_EW_RED;
                endcase
            end
            
            NS_RED_EW_GREEN: begin
                {ew_lights, ns_lights} = 4'b0110;  // EW=GREEN, NS=RED
                if (emergency)
                    next_state = EMERGENCY_ALL_RED;
                else if (counter_of)
                    next_state = NS_RED_EW_YELLOW;
                else
                    next_state = NS_RED_EW_GREEN;
            end
            
            NS_RED_EW_YELLOW: begin
                {ew_lights, ns_lights} = 4'b1110;  // EW=YELLOW, NS=RED
                casez({counter_of, emergency, pedestrian_req})
                    3'b11?: next_state = EMERGENCY_ALL_RED;
                    3'b101: next_state = PEDESTRIAN_CROSSING;
                    3'b100: next_state = NS_GREEN_EW_RED;
                    default: next_state = NS_RED_EW_YELLOW;
                endcase
            end
            
            EMERGENCY_ALL_RED: begin
                emergency_active = 1;
                {ew_lights, ns_lights} = counter[0] ? 4'b1010 : 4'b0000;  // Flashing RED
				if(~emergency) begin next_state = NS_GREEN_EW_RED; end
            end
            
            PEDESTRIAN_CROSSING: begin
                ped_walk = 1;
                {ew_lights, ns_lights} = 4'b1010;  // Both RED
                casez({emergency, counter_of})
                    2'b1?: begin
                        emergency_active = 1;
                        next_state = EMERGENCY_ALL_RED;
                    end
                    2'b01: next_state = NS_GREEN_EW_RED;
                    default: next_state = PEDESTRIAN_CROSSING;
                endcase
            end
            
            default: next_state = STARTUP_FLASH;
        endcase
    end
    
endmodule

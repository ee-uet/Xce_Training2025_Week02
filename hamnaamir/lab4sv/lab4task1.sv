typedef enum logic [2:0] {
    IDLE                 = 3'b000,
    START_FLASH          = 3'b001,
    NS_GREEN_EW_RED      = 3'b010,
    NS_YELLOW_EW_RED     = 3'b011,
    NS_RED_EW_GREEN      = 3'b100,
    NS_RED_EW_YELLOW     = 3'b101,
    EMERGENCY            = 3'b110,
    PEDESTRIAN_CROSSING  = 3'b111
} state_t;

module traffic_controller (
    input  logic       clk,           // 1 Hz
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [1:0] ns_lights,     // [G1,Y0? adjust mapping as you need]
    output logic [1:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);
    state_t prev_state, current_state, next_state;
    logic [5:0] counter;

    // Duration counter
    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        counter <= '0;
      end else if (current_state != next_state) begin
        counter <= '0;                 // reset when state changes
      end else begin
        counter <= counter + 6'd1;     // count seconds (1 Hz clk)
      end
    end

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            prev_state    <= IDLE;
        end else begin
            // Remember where we came from when entering special modes
            if (next_state == EMERGENCY && current_state != EMERGENCY)
                prev_state <= current_state;
            else if (next_state == PEDESTRIAN_CROSSING && current_state != PEDESTRIAN_CROSSING)
                prev_state <= current_state;

            current_state <= next_state;
        end
    end

    // Next-state logic
    always_comb begin
        next_state = current_state; // default

        unique case (current_state)
            IDLE: begin
                if (!emergency && !pedestrian_req)
                    next_state = START_FLASH;
            end

            START_FLASH: begin
                if (!emergency && !pedestrian_req)
                    next_state = NS_GREEN_EW_RED;
            end

            NS_GREEN_EW_RED: begin
                if (!emergency && !pedestrian_req && counter == 6'd30)
                    next_state = NS_YELLOW_EW_RED;
                else if (emergency && !pedestrian_req && counter == 6'd5)
                    next_state = EMERGENCY;
                else if (!emergency && pedestrian_req && counter == 6'd30)
                    next_state = PEDESTRIAN_CROSSING;
            end

            NS_YELLOW_EW_RED: begin
                if (!emergency && !pedestrian_req && counter == 6'd30)
                    next_state = NS_RED_EW_GREEN;
                else if (emergency && !pedestrian_req && counter == 6'd5)
                    next_state = EMERGENCY;
                else if (!emergency && pedestrian_req && counter == 6'd30)
                    next_state = PEDESTRIAN_CROSSING;
            end

            NS_RED_EW_YELLOW: begin
                if (!emergency && !pedestrian_req && counter == 6'd30)
                    next_state = NS_RED_EW_GREEN;
                else if (emergency && !pedestrian_req && counter == 6'd5)
                    next_state = EMERGENCY;
                else if (!emergency && pedestrian_req && counter == 6'd30)
                    next_state = PEDESTRIAN_CROSSING;
            end

            NS_RED_EW_GREEN: begin
                if (!emergency && !pedestrian_req && counter == 6'd30)
                    next_state = START_FLASH;
                else if (emergency && !pedestrian_req && counter == 6'd5)
                    next_state = EMERGENCY;
                else if (!emergency && pedestrian_req && counter == 6'd30)
                    next_state = PEDESTRIAN_CROSSING;
            end

            EMERGENCY: begin
                if (!emergency)
                    next_state = prev_state;  // return
            end

            PEDESTRIAN_CROSSING: begin
                if (!pedestrian_req)
                    next_state = prev_state;  // return
            end

            default: next_state = IDLE;
        endcase
    end

    // Output logic (Moore)
    always_comb begin
        // safe defaults
        ns_lights        = 2'b00;
        ew_lights        = 2'b00;
        ped_walk         = 1'b0;
        emergency_active = 1'b0;

        unique case (current_state)
            START_FLASH: begin
                ns_lights = 2'b01;
                ew_lights = 2'b01;
            end

            NS_GREEN_EW_RED: begin
                ns_lights = 2'b10;
                ew_lights = 2'b00;
            end

            NS_YELLOW_EW_RED: begin
                ns_lights = 2'b01;
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

            EMERGENCY: begin
                ns_lights        = 2'b00;
                ew_lights        = 2'b00;
                emergency_active = 1'b1;
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights = 2'b00;
                ew_lights = 2'b00;
                ped_walk  = 1'b1;
            end

            default: ; // keep defaults
        endcase
    end

endmodule

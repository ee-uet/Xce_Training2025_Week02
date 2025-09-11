module traffic_controller (
    input  logic       clk,           // 1 Hz
    input  logic       rst_n,
    input  logic       emergency,
    input  logic       pedestrian_req,
    output logic [1:0] ns_lights,     // [Red, Yellow, Green]
    output logic [1:0] ew_lights,
    output logic       ped_walk,
    output logic       emergency_active
);

    // TODO: Define states and implement FSM
    // Consider: How to handle competing requests?
    // Define state enumeration
typedef enum logic [2:0] {
    IDLE = 3'b000,
    STARTUP_FLASH = 3'b001,
	NS_GREEN_EW_RED = 3'b010,
	NS_YELLOW_EW_RED = 3'b011, 
    NS_RED_EW_GREEN = 3'b100,
    NS_RED_EW_YELLOW = 3'b101,
	EMERGENCY_ALL_RED = 3'b110,
	PEDESTRIAN_CROSSING = 3'b111
    // TODO: Add more states
} state_t;

    state_t current_state, next_state, prev_state;
    
    // State register - ALWAYS separate this
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            prev_state <= IDLE;
        end else begin
         if (next_state == EMERGENCY_ALL_RED && current_state != EMERGENCY_ALL_RED) begin
            prev_state <= current_state;   // save previous
        end
        if (next_state == PEDESTRIAN_CROSSING  && current_state != PEDESTRIAN_CROSSING) begin
            prev_state <= current_state;   // save previous
        end
        current_state <= next_state;
        end
    end
logic [4:0] counter;
    // Next state logic - ALWAYS use always_comb
    always_comb begin
        next_state = current_state; // Default assignment prevents latches
         
        case (current_state)
            // TODO: Implement state transitions
        IDLE: begin
        next_state = STARTUP_FLASH;
        end
        STARTUP_FLASH: begin
        if ( emergency == 0 && pedestrian_req == 0)
             next_state = NS_GREEN_EW_RED;
        else
             next_state = STARTUP_FLASH;
        end
        NS_GREEN_EW_RED:begin
        if (emergency == 0 && pedestrian_req == 0) begin
             if (counter == 30)
               next_state = NS_YELLOW_EW_RED;
             else
               next_state = NS_GREEN_EW_RED;
        end
        else if (emergency == 1 && pedestrian_req == 0) begin
              if (counter == 30)
               next_state = EMERGENCY_ALL_RED;
             else
               next_state = NS_GREEN_EW_RED;
        end
        else if (emergency == 0  && pedestrian_req == 1) begin
               if (counter == 30)
               next_state = PEDESTRIAN_CROSSING;
             else
               next_state = NS_GREEN_EW_RED;
        end
        else if (emergency == 1  && pedestrian_req == 1) begin
               if (counter == 30)
               next_state = PEDESTRIAN_CROSSING;
              else
               next_state = NS_GREEN_EW_RED;
        end
        else 
            next_state = NS_GREEN_EW_RED;
        end
        NS_YELLOW_EW_RED: begin
        if (emergency == 0 && pedestrian_req == 0) begin
             if (counter == 5)
               next_state = NS_RED_EW_GREEN;
             else
               next_state = NS_YELLOW_EW_RED;
        end
        else if (emergency == 1 && pedestrian_req == 0) 
               next_state = EMERGENCY_ALL_RED;
        else if (emergency == 0  && pedestrian_req == 1) 
               next_state = PEDESTRIAN_CROSSING;     
        else if (emergency == 1  && pedestrian_req == 1) 
               next_state = PEDESTRIAN_CROSSING;
        else 
            next_state = NS_YELLOW_EW_RED;
        end
        NS_RED_EW_GREEN: begin
         if (emergency == 0 && pedestrian_req == 0) begin
             if (counter == 30)
               next_state = NS_RED_EW_YELLOW;
             else
               next_state = NS_RED_EW_GREEN;
         end
        else if (emergency == 1 && pedestrian_req == 0) begin
              if (counter == 30)
               next_state = EMERGENCY_ALL_RED;
              else
               next_state = NS_RED_EW_GREEN;
        end
        else if (emergency == 0  && pedestrian_req == 1) begin
               if (counter == 30)
               next_state = PEDESTRIAN_CROSSING;
             else
               next_state = NS_RED_EW_GREEN;
        end
         else if (emergency == 1  && pedestrian_req == 1) begin
               if (counter == 30)
               next_state = PEDESTRIAN_CROSSING;
             else
               next_state = NS_RED_EW_GREEN;
         end
        else 
            next_state = NS_RED_EW_GREEN;
        end
        NS_RED_EW_YELLOW: begin
           if (emergency == 0 && pedestrian_req == 0) begin
             if (counter == 5)
               next_state = NS_GREEN_EW_RED;
             else
               next_state = NS_RED_EW_YELLOW;
           end
           else if (emergency == 1 && pedestrian_req == 0) 
               next_state = EMERGENCY_ALL_RED;
           else if (emergency == 0  && pedestrian_req == 1) 
               next_state = PEDESTRIAN_CROSSING;
           else if (emergency == 1  && pedestrian_req == 1) 
               next_state = PEDESTRIAN_CROSSING;
          else 
            next_state = NS_RED_EW_YELLOW;
        end
        EMERGENCY_ALL_RED:  begin
        if (emergency) begin
           if (counter == 15)
            next_state = prev_state;
           else
           next_state = EMERGENCY_ALL_RED;
        end
        else
          next_state = prev_state;
        end
        PEDESTRIAN_CROSSING:begin
        if (pedestrian_req) begin
         if (counter == 15)
          next_state =  prev_state;
         else
          next_state = PEDESTRIAN_CROSSING;
        end
        else
          next_state = prev_state;
        end
        endcase
    end
always_comb begin
  case (current_state) 
  IDLE: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b000000;
  STARTUP_FLASH: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b101000;
  NS_GREEN_EW_RED: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b110100;
  NS_YELLOW_EW_RED: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b100100;
  NS_RED_EW_GREEN: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b011100;
  NS_RED_EW_YELLOW:  {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b011000;
  EMERGENCY_ALL_RED: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b010110;
  PEDESTRIAN_CROSSING: {ns_lights,ew_lights,emergency_active,ped_walk} = 6'b000001;
  endcase
end
    // Output logic - Separate from state logic
    // TODO: Implement Moore or Mealy outputs
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
     counter <= 0;
   end
   else if (current_state != next_state) 
        counter <= 0;   // reset counter on state change
   else begin
     counter <= counter +1;
   end
end
endmodule

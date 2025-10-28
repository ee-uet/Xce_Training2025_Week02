typedef enum logic [2:0] {
    STARTUP_FLASH        = 3'b000,
    NS_GREEN_EW_RED      = 3'b001,
    NS_YELLOW_EW_RED     = 3'b010,
    NS_RED_EW_GREEN      = 3'b011,
    NS_RED_EW_YELLOW     = 3'b100,
    PEDESTRIAN_CROSSING  = 3'b101,
    EMERGENCY_ALL_RED    = 3'b110
} state_t;

module TrafficControl_FSM (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        emergency,
    input  logic        pedestrian_req,
    input  logic        count_done,
    output logic [1:0]  ns_lights,  
    output logic [1:0]  ew_lights,
    output logic        ped_walk,
    output logic        emergency_active,
    output logic        count_start,
    output logic [4:0]  count_value
);

    state_t c_state, n_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            c_state <= STARTUP_FLASH;
        else
            c_state <= n_state;
    end

    // Next-state logic
    always_comb begin
        n_state = c_state;
        case (c_state)
            STARTUP_FLASH: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done) n_state = NS_GREEN_EW_RED;
            end
            NS_GREEN_EW_RED: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done) n_state = NS_YELLOW_EW_RED;
            end
            NS_YELLOW_EW_RED: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done) n_state = NS_RED_EW_GREEN;
            end
            NS_RED_EW_GREEN: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done) n_state = NS_RED_EW_YELLOW;
            end
            NS_RED_EW_YELLOW: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done && pedestrian_req) n_state = PEDESTRIAN_CROSSING;
                else if (count_done && !pedestrian_req) n_state = NS_GREEN_EW_RED;
            end
            PEDESTRIAN_CROSSING: begin
                if (emergency) n_state = EMERGENCY_ALL_RED;
                else if (count_done) n_state = NS_GREEN_EW_RED;
            end
            EMERGENCY_ALL_RED: begin
                if (!emergency) n_state = STARTUP_FLASH;
            end
        endcase
    end

    // Output logic
    always_comb begin
        // Defaults
        ns_lights        = 2'b11; 
        ew_lights        = 2'b11;
        ped_walk         = 1'b0;
        emergency_active = 1'b0;
        count_start      = 1'b0;
        count_value      = 5'd0;

        case (c_state)
            STARTUP_FLASH: begin
                ns_lights   = 2'b00;  
                ew_lights   = 2'b00;
                count_start = 1'b1;
                count_value = 5'd10;
            end
            NS_GREEN_EW_RED: begin
                ns_lights   = 2'b01;
                ew_lights   = 2'b11;
                count_start = 1'b1;
                count_value = 5'd30;
            end
            NS_YELLOW_EW_RED: begin
                ns_lights   = 2'b10;
                ew_lights   = 2'b11;
                count_start = 1'b1;
                count_value = 5'd5;
            end
            NS_RED_EW_GREEN: begin
                ns_lights   = 2'b11;
                ew_lights   = 2'b01;
                count_start = 1'b1;
                count_value = 5'd30;
            end
            NS_RED_EW_YELLOW: begin
                ns_lights   = 2'b11;
                ew_lights   = 2'b10;
                count_start = 1'b1;
                count_value = 5'd5;
            end
            PEDESTRIAN_CROSSING: begin
                ns_lights   = 2'b11;
                ew_lights   = 2'b11;
                ped_walk    = 1'b1;
                count_start = 1'b1;
                count_value = 5'd10;
            end
            EMERGENCY_ALL_RED: begin
                ns_lights        = 2'b11;
                ew_lights        = 2'b11;
                emergency_active = 1'b1;
            end
        endcase
    end

endmodule

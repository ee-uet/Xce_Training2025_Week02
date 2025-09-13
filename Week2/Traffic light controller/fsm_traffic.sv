typedef enum logic [2:0] {
    STARTUP_FLASH       = 3'b000,
    NS_GREEN_EW_RED     = 3'b001,
    NS_YELLOW_EW_RED    = 3'b010,
    NS_RED_EW_GREEN     = 3'b011,
    NS_RED_EW_YELLOW    = 3'b100,
    PEDESTRIAN_CROSSING = 3'b101,
    EMERGENCY_ALL_RED   = 3'b110
} state_t;


module fsm_traffic (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        emergency,
    input  logic        pedestrian_req,
    input  logic        count_done,

    output logic [1:0]  ns_lights,      // 00-> red_flashing, 01-> green, 10-> yellow, 11-> red
    output logic [1:0]  ew_lights,
    output logic        ped_walk,
    output logic        emergency_active,
    output logic        count_start,
    output logic [4:0]  count_value
);

    state_t c_state, n_state;

    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            c_state <= STARTUP_FLASH;
        else        
            c_state <= n_state;
    end

    // ------------------------------------------------------------
    // Next state logic
    // ------------------------------------------------------------
    always_comb begin
        n_state = c_state;

        unique case (c_state)
            STARTUP_FLASH: begin
                if (emergency)        n_state = EMERGENCY_ALL_RED;
                else if (count_done)  n_state = NS_GREEN_EW_RED;
            end

            NS_GREEN_EW_RED: begin
                if (emergency)        n_state = EMERGENCY_ALL_RED;
                else if (count_done)  n_state = NS_YELLOW_EW_RED;
            end

            NS_YELLOW_EW_RED: begin
                if (emergency)        n_state = EMERGENCY_ALL_RED;
                else if (count_done)  n_state = NS_RED_EW_GREEN;
            end

            NS_RED_EW_GREEN: begin
                if (emergency)        n_state = EMERGENCY_ALL_RED;
                else if (count_done)  n_state = NS_RED_EW_YELLOW;
            end

            NS_RED_EW_YELLOW: begin
                if (emergency)                  n_state = EMERGENCY_ALL_RED;
                else if (count_done && pedestrian_req)  
                                                 n_state = PEDESTRIAN_CROSSING;
                else if (count_done && !pedestrian_req) 
                                                 n_state = NS_GREEN_EW_RED;
            end

            PEDESTRIAN_CROSSING: begin
                if (emergency)        n_state = EMERGENCY_ALL_RED;
                else if (!pedestrian_req) 
                                        n_state = NS_GREEN_EW_RED;
            end

            EMERGENCY_ALL_RED: begin
                if (!emergency)       n_state = STARTUP_FLASH;
            end

            default:                  n_state = STARTUP_FLASH;
        endcase
    end

    // ------------------------------------------------------------
    // Output logic
    // ------------------------------------------------------------
    always_comb begin
        // Default values
        ns_lights        = 2'b11;  // red
        ew_lights        = 2'b11;  // red
        ped_walk         = 1'b0;
        emergency_active = 1'b0;
        count_start      = 1'b0;
        count_value      = 5'd0;

        unique case (c_state)
            STARTUP_FLASH: begin
                ns_lights   = 2'b00;  // flashing red
                ew_lights   = 2'b00;
                count_start = 1'b1;
                count_value = 5'd10;  // flash for 10s
            end

            NS_GREEN_EW_RED: begin
                ns_lights   = 2'b01;  // NS green
                ew_lights   = 2'b11;  // EW red
                count_start = 1'b1;
                count_value = 5'd30;  // 30s
            end

            NS_YELLOW_EW_RED: begin
                ns_lights   = 2'b10;  // NS yellow
                ew_lights   = 2'b11;  // EW red
                count_start = 1'b1;
                count_value = 5'd5;   // 5s
            end

            NS_RED_EW_GREEN: begin
                ns_lights   = 2'b11;  // NS red
                ew_lights   = 2'b01;  // EW green
                count_start = 1'b1;
                count_value = 5'd30;  // 30s
            end

            NS_RED_EW_YELLOW: begin
                ns_lights   = 2'b11;  // NS red
                ew_lights   = 2'b10;  // EW yellow
                count_start = 1'b1;
                count_value = 5'd5;   // 5s
            end

            PEDESTRIAN_CROSSING: begin
                ns_lights   = 2'b11;  // red
                ew_lights   = 2'b11;  // red
                ped_walk    = 1'b1;   // walk signal
            end

            EMERGENCY_ALL_RED: begin
                ns_lights        = 2'b00; // flashing red
                ew_lights        = 2'b00;
                emergency_active = 1'b1;
            end
        endcase
    end

endmodule

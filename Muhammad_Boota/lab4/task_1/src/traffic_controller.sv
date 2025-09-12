import pkg::*;
module traffic_controller (
input  logic clk,// 1 Hz
input  logic rst_n,
input  logic emergency,
input  logic pedestrian_req,
output traffic_lights ns_lights, // [Red, Yellow, Green]
output traffic_lights ew_lights,
output logic ped_walk,
output logic emergency_active
);

logic load;
logic enable;
logic up_down;
logic [7:0] load_value;
logic [7:0] max_count;
logic [7:0] count;
logic tc; // Terminal 
logic zero;
// TOD: 

programmable_counter PG(
    .*
);
// TOD: Define states and implement FSM

traffic curr_state,next_state;

always_comb begin 
    load=1'b0;
    up_down=1'b0;
    load_value=8'b0;
    max_count=8'd255;
    case (curr_state)
        STARTUP_FLASH:if(emergency)begin
                next_state=EMERGENCY_ALL_RED; 
            end else if(zero)begin
                next_state= NS_GREEN_EW_RED;
                load_value=8'd30;
                load=1'b1;
            end else begin 
                next_state=STARTUP_FLASH;
            end

        NS_GREEN_EW_RED:if(emergency)begin
                next_state=EMERGENCY_ALL_RED;
            end else if (zero)begin 
                next_state= NS_YELLOW_EW_RED;
                load_value=8'd5;
                load=1'b1;
            end else begin
                next_state=NS_GREEN_EW_RED;
            end
        NS_YELLOW_EW_RED:if(emergency) begin
                next_state=EMERGENCY_ALL_RED;
            end else if (zero) begin 
                next_state= NS_RED_EW_GREEN;
                load_value=8'd30;
                load=1'b1; 
            end else begin 
                next_state=NS_YELLOW_EW_RED;
            end
        NS_RED_EW_GREEN:if(emergency)begin 
                next_state=EMERGENCY_ALL_RED; 
            end else if (zero)begin
                next_state= NS_RED_EW_YELLOW;
                load_value=8'd5;
                load=1'b1;
            end else begin 
                next_state=NS_RED_EW_GREEN;
            end
        NS_RED_EW_YELLOW:if(emergency)begin
                next_state=EMERGENCY_ALL_RED;
            end else if (pedestrian_req && zero)begin
                next_state=PEDESTRIAN_CROSSING;
                load_value=8'd20;
                load=1'b1;
            end else if (zero)begin
                next_state= NS_GREEN_EW_RED;
                load_value=8'd30;
                load=1'b1;
            end else begin
                    next_state=NS_RED_EW_YELLOW;
            end
        EMERGENCY_ALL_RED:if(!emergency)begin 
                next_state=NS_GREEN_EW_RED;
                load_value=8'd30;
                load=1'b1;
            end else begin 
                next_state=EMERGENCY_ALL_RED;
            end
        PEDESTRIAN_CROSSING:if (zero)begin
                next_state=NS_GREEN_EW_RED;
                load_value=8'd30;
                load=1'b1;
            end else begin
                next_state=PEDESTRIAN_CROSSING;
            end
        default: next_state=STARTUP_FLASH;
    endcase
end
always_ff @( posedge clk ) begin 
    if (!rst_n)
        curr_state<=STARTUP_FLASH; 
    else
        curr_state<=next_state;
end

// Consider: How to handle competing requests?
always_comb begin 
    ns_lights=RED;
    ew_lights=RED;
    enable=1'b0;
    emergency_active=1'b0;
    ped_walk=1'b0;
    case (curr_state)
        NS_GREEN_EW_RED:begin
            ns_lights=GREEN;
            ew_lights=RED;
            enable=1'b1;
        end
        NS_YELLOW_EW_RED:begin
            ns_lights=YELLOW;
            ew_lights=RED;
            enable=1'b1;
        end
        NS_RED_EW_GREEN:begin
            ns_lights=RED;
            ew_lights=GREEN;
            enable=1'b1;
        end
        NS_RED_EW_YELLOW:begin
            ns_lights=RED;
            ew_lights=YELLOW;
            enable=1'b1;
        end
        PEDESTRIAN_CROSSING:begin
            ns_lights=RED;
            ew_lights=RED;
            ped_walk=1'b1;
            enable=1'b1;
        end
        EMERGENCY_ALL_RED:begin
            ns_lights=RED;
            ew_lights=RED;
            emergency_active=1'b1;
        end
        default: begin
            ns_lights=RED;
            ew_lights=RED;
            emergency_active=1'b0;
            ped_walk=1'b0;
            enable=1'b0;
        end
    endcase
end

endmodule
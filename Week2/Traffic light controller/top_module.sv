/*
    Top module for traffic light controller
    Features:
    - North-South and East-West traffic lights
    - Pedestrian crossing control
    - Emergency vehicle handling
    - Integrated FSM + Timer modules
*/

module top_module (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        emergency,
    input  logic        pedestrian_req,

    output logic [1:0]  ns_lights,       // 00-> red_flashing, 01-> green, 10-> yellow, 11-> red
    output logic [1:0]  ew_lights,
    output logic        ped_walk,
    output logic        emergency_active
);

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------
    logic        count_start;
    logic [4:0]  count_value;
    logic        count_done;

    // ------------------------------------------------------------
    // FSM instance
    // ------------------------------------------------------------
    fsm_traffic fsm_inst (
        .clk              (clk),
        .rst_n            (rst_n),
        .emergency        (emergency),
        .pedestrian_req   (pedestrian_req),
        .count_done       (count_done),

        .ns_lights        (ns_lights),
        .ew_lights        (ew_lights),
        .ped_walk         (ped_walk),
        .emergency_active (emergency_active),

        .count_start      (count_start),
        .count_value      (count_value)
    );

    // ------------------------------------------------------------
    // Timer instance
    // ------------------------------------------------------------
    timer timer_inst (
        .clk         (clk),
        .rst_n       (rst_n),
        .count_start (count_start),
        .count_value (count_value),
        .count_done  (count_done)
    );

endmodule

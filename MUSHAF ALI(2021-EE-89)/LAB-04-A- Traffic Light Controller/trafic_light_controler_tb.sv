`timescale 1ns/1ps

module tb_trafic_light_controller;

    // Clock and reset
    logic clk;
    logic rst;

    // Emergency and pedestrian signals
    logic emergency;
    logic padestrian_req;

    // Timer outputs
    logic time_10s, time_30s, time_5s;
    logic emergency_reset, padestrian_reset;

    // Traffic lights outputs
    logic [2:0] ns_lights, es_lights;
    logic ps_walk;

    // Instantiate Timer
    clk_to_timer timer_inst (
        .clk(clk),
        .rst(rst),
        .emergency_reset(emergency_reset),
        .padestrian_reset(padestrian_reset),
        .time_30s(time_30s),
        .time_10s(time_10s),
        .time_5s(time_5s)
    );

    // Instantiate Traffic Light Controller
    trafic_light_controler fsm_inst (
        .clk(clk),
        .rst(rst),
        .time_10s(time_10s),
        .time_30s(time_30s),
        .time_5s(time_5s),
        .emergency(emergency),
        .padestrian_req(padestrian_req),
        .emergency_reset(emergency_reset),
        .padestrian_reset(padestrian_reset),
        .ns_lights(ns_lights),
        .es_lights(es_lights),
        .ps_walk(ps_walk)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz fast clock for simulation

    // Stimulus
    initial begin
        rst = 1;
        emergency = 0;
        padestrian_req = 0;
        #50;
        rst = 0;

        // Let FSM run normally
        #200;

        // Pedestrian request
        padestrian_req = 1;
        #20;
        padestrian_req = 0;

        #200;

        // Emergency trigger
        emergency = 1;
        #50;
        emergency = 0;

        #200;

        $finish;
    end

    // Monitor signals
    initial begin
        $display("Time\tclk\tns_lights\tes_lights\tps_walk\tt10s\tt30s\tt5s");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                  $time, clk, ns_lights, es_lights, ps_walk, time_10s, time_30s, time_5s);
    end
endmodule

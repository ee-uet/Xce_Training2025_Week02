`timescale 1ns/1ps

module tb_traffic_controller;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [1:0] ns_lights;
    logic [1:0] ew_lights;
    logic ped_walk;
    logic emergency_active;

    // Instantiate DUT
    traffic_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .emergency(emergency),
        .pedestrian_req(pedestrian_req),
        .ns_lights(ns_lights),
        .ew_lights(ew_lights),
        .ped_walk(ped_walk),
        .emergency_active(emergency_active)
    );

    // Clock generation (1 Hz → here just toggle every 5ns for simulation speed)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;
        #20;
        rst_n = 1;

        // Normal traffic sequence
        repeat (40) @(posedge clk);

        // Pedestrian request
        pedestrian_req = 1;
        repeat (40) @(posedge clk);
        pedestrian_req = 0;

        // Emergency case
        emergency = 1;
        repeat (20) @(posedge clk);
        emergency = 0;

        // Run some more
        repeat (40) @(posedge clk);

        $stop;  // end simulation
    end

    // Monitor outputs
    initial begin
        $monitor("T=%0t | state ns=%b ew=%b ped=%b emg=%b",
                  $time, ns_lights, ew_lights, ped_walk, emergency_active);
    end

endmodule

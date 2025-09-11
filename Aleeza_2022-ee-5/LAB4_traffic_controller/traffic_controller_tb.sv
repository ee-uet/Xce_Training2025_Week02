module traffic_controller_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [2:0] ns_lights;
    logic [2:0] ew_lights;
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

    // Clock generation (1 Hz equivalent in simulation: 10ns period here)
    always #5 clk = ~clk;

    // Helper task to display DUT outputs
    task show_outputs(input string msg);
        $display("[%0t] %s | NS=%b EW=%b PedWalk=%b Emergency=%b",
                 $time, msg, ns_lights, ew_lights, ped_walk, emergency_active);
    endtask

    // Stimulus
    initial begin
        // Init signals
        clk = 0;
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;

        // Reset
        repeat (2) @(posedge clk);
        rst_n = 1;
        show_outputs("Reset released");

        // Normal sequence
        repeat (35) @(posedge clk); show_outputs("Normal cycle running");


        // Emergency triggered
        emergency = 1;
        repeat (5) @(posedge clk);
        show_outputs("Emergency active (all red)");

        // Emergency cleared
        emergency = 0;
        repeat (10) @(posedge clk);
        show_outputs("Emergency cleared, normal resumed");
        
        // Pedestrian request
        pedestrian_req = 1;
        repeat (5) @(posedge clk);
        show_outputs("Pedestrian crossing handled");
        pedestrian_req = 0;
        // Resume normal cycle
        repeat (20) @(posedge clk);
        show_outputs("Back to normal cycle");

        $finish;
    end

endmodule


module tb_traffic_controller;

    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [1:0] ns_lights;
    logic [1:0] ew_lights;
    logic ped_walk;
    logic emergency_active;

    traffic_controller uut (.*);

    initial clk = 0;
    always #5 clk = ~clk; 

    initial begin
        // Initial values
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;

        // Reset
        #20;
        rst_n = 1;
        repeat(40) @(posedge clk);

        // Trigger pedestrian request
        pedestrian_req = 1;
        repeat(10) @(posedge clk);
        pedestrian_req = 0;

        // Run few more cycles
        repeat(20) @(posedge clk);

        // Trigger emergency
        emergency = 1;
        repeat(15) @(posedge clk);
        emergency = 0;

        // Run some more cycles to return to prev state
        repeat(30) @(posedge clk);
        $stop;
    end

    // Monitor states
    initial begin
        $monitor("T=%0t | ns=%b ew=%b ped=%b emerg=%b",
                 $time, ns_lights, ew_lights, ped_walk, emergency_active);
    end

endmodule

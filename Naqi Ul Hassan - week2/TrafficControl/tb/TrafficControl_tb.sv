module TrafficControl_tb;

    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [1:0] ns_lights;
    logic [1:0] ew_lights;
    logic ped_walk;
    logic emergency_active;

    // DUT
    Top dut (
        .clk                (clk),
        .rst_n              (rst_n),
        .emergency          (emergency),
        .pedestrian_req     (pedestrian_req),
        .ns_lights          (ns_lights),
        .ew_lights          (ew_lights),
        .ped_walk           (ped_walk),
        .emergency_active   (emergency_active)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor signals
    initial begin
        $display("Time | NS | EW | Ped | Emerg");
        $monitor("%4t | %2b | %2b |  %1b  |   %1b",
                 $time, ns_lights, ew_lights, ped_walk, emergency_active);
    end

    // Stimulus
    initial begin
        // Reset
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;
        @(posedge clk);
        rst_n = 1;

        // Let startup flash run
        repeat (40) @(posedge clk);

        // Normal cycle: NS green, EW red
        repeat (30) @(posedge clk);

        // Request pedestrian crossing
        pedestrian_req = 1;
        repeat (15) @(posedge clk);
        pedestrian_req = 0;

        // Trigger emergency mode
        emergency = 1;
        repeat (20) @(posedge clk);
        emergency = 0;

        // Let system recover to normal operation
        repeat (50) @(posedge clk);

        $finish;
    end

endmodule

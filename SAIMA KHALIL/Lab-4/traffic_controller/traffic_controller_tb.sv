module traffic_controller_tb;

    // DUT signals
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

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units per cycle
    end

    // Stimulus synchronized to posedge
    initial begin
        // Initialize
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;

        // Reset deassert on next clock
        @(posedge clk);
        rst_n <= 1;

        // Wait a few cycles for startup flash
        repeat(3) @(posedge clk);

        // Pedestrian request
        @(posedge clk);
        pedestrian_req <= 1;
        @(posedge clk);
        pedestrian_req <= 0;

        // Let traffic run normally for a while
        repeat(10) @(posedge clk);

        // Trigger emergency
        @(posedge clk);
        emergency <= 1;
        repeat(3) @(posedge clk);
        emergency <= 0;

        // Let it run more cycles
        repeat(15) @(posedge clk);

        $stop;
    end

    // Monitor outputs
    initial begin
        $display("Time\tState\tNS\tEW\tPed\tEmerg");
        forever @(posedge clk) begin
            $display("%0t\t%b\t%0b\t%0b\t%b\t%b",
                     $time, dut.current_state, ns_lights, ew_lights, ped_walk, emergency_active);
        end
    end

endmodule

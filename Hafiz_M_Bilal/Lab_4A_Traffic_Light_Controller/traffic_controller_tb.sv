module traffic_controller_tb;
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

    // Clock: 1 Hz -> 1s period (use #5 = 1s for faster sim)
    initial clk = 0;
    always #5 clk = ~clk;  // 10 time units = 1 "second"

    // ------------ Debug printing -------------
    // decode lights for readability
    function string lights_to_str(input logic [1:0] l);
        case (l)
            2'b00: lights_to_str = "RED";
            2'b01: lights_to_str = "GREEN";
            2'b10: lights_to_str = "YELLOW";
            2'b11: lights_to_str = "OFF";
            default: lights_to_str = "??";
        endcase
    endfunction

    // state string from DUT
    function string state_to_str(input int s);
        case (s)
            0: state_to_str = "STARTUP_FLASH";
            1: state_to_str = "NS_GREEN_EW_RED";
            2: state_to_str = "NS_YELLOW_EW_RED";
            3: state_to_str = "NS_RED_EW_GREEN";
            4: state_to_str = "NS_RED_EW_YELLOW";
            5: state_to_str = "PEDESTRIAN_CROSSING";
            6: state_to_str = "EMERGENCY_ALL_RED";
            default: state_to_str = "???";
        endcase
    endfunction

    // monitor changes every clock
    always @(posedge clk) begin
        $display("[%0t] State=%s | NS=%s | EW=%s | Ped=%b | Emergency=%b | Timer=%0d",
                  $time,
                  state_to_str(dut.state),
                  lights_to_str(ns_lights),
                  lights_to_str(ew_lights),
                  ped_walk,
                  emergency_active,
                  dut.timer_count);
    end

    // ------------ Stimulus -------------
    initial begin
        // Initialize
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;
        #20 rst_n = 1;


        if (pedestrian_req) $display("[%0t] Pedestrian button pressed", $time);
        if (dut.ped_latch)      $display("[%0t] Pedestrian request latched", $time);
        if (emergency)      $display("[%0t] Emergency ACTIVE", $time);

        // Let it run for a while
        repeat(20) @(posedge clk);

        // Pedestrian request
        //repeat(40) @(posedge clk);
        $display(">>> Pedestrian request!");
        pedestrian_req = 1;
        @(posedge clk);
        pedestrian_req = 0;

        repeat(28) @(posedge clk);

        // Emergency
        $display(">>> Emergency triggered!");
        emergency = 1;
        repeat(10) @(posedge clk);
        emergency = 0;

        repeat(30) @(posedge clk);

        $display("Simulation finished.");
        $stop;
    end
endmodule

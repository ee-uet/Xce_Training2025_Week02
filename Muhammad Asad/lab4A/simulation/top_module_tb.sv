module top_module_tb;

    logic clk;
    logic rst_n;
    logic emergency;
    logic pedestrian_req;
    logic [1:0] ns_lights;
    logic [1:0] ew_lights;
    logic ped_walk;
    logic emergency_active;

    // Instantiate DUT
    top_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .emergency(emergency),
        .pedestrian_req(pedestrian_req),
        .ns_lights(ns_lights),
        .ew_lights(ew_lights),
        .ped_walk(ped_walk),
        .emergency_active(emergency_active)
    );

    
    initial clk = 0;
    always #5 clk = ~clk;

    
    initial begin
        rst_n = 0; emergency = 0; pedestrian_req = 0;
        #3;
        rst_n = 1;
        // Testing transition from start up state to NSgreen_EWRED
        repeat (20) @(posedge clk);

        // Testing Pedestrian request
        pedestrian_req = 1;
        repeat (2) @(posedge clk);
        pedestrian_req = 0;
        // Testing Emergency
        emergency = 1;
        repeat (3) @(posedge clk);
        emergency = 0;
        repeat (10) @(posedge clk);

        $finish;
    end

    

endmodule
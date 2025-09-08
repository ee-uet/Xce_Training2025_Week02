module tb_traffic_controller();
    logic       clk;
    logic       rst_n;
    logic       emergency;
    logic       pedestrian_req;
    logic [1:0] ns_lights;
    logic [1:0] ew_lights;
    logic       ped_walk;
    logic       emergency_active;
    
    // Clock generation (1 Hz)
    always #500 clk = ~clk; // 500ms period for 1Hz clock
    
    // Instantiate the traffic controller
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
    
    // Helper function to interpret light values
    function string light_to_string(logic [1:0] light);
        case(light)
            2'b00: return "OFF";
            2'b01: return "GREEN";
            2'b10: return "RED";
            2'b11: return "YELLOW"; 
            default: return "UNKNOWN";
        endcase
    endfunction
    
    // Helper function to check if pedestrian request should be entertained
    function bit is_ped_req_valid();
        // Pedestrian request is only entertained during RED or YELLOW states
        return (ns_lights == 2'b10 || ns_lights == 2'b11 || 
                ew_lights == 2'b10 || ew_lights == 2'b11);
    endfunction
    
    initial begin
        // Initialize VCD dump
        $dumpfile("4A.vcd");
        $dumpvars(0, tb_traffic_controller);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;
        emergency = 0;
        pedestrian_req = 0;
        
        // Test 1: Reset and startup (synchronous)
        @(posedge clk);
        rst_n = 1;
        $display("Time=%t: Reset released - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Wait for startup to complete (synchronous)
        repeat(10) @(posedge clk);
        $display("Time=%t: After startup - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Test 2: Normal operation - let it cycle through states
        repeat(30) @(posedge clk);
        $display("Time=%t: Normal operation - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Test 3: Wait for appropriate state to test pedestrian request
        // Wait until we're in a RED or YELLOW state
        while(~(is_ped_req_valid())) @(posedge clk);
        
        // Assert pedestrian request synchronously
        pedestrian_req = 1;
        $display("Time=%t: Pedestrian request asserted (Valid state) - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        @(posedge clk);
        pedestrian_req = 0;
        $display("Time=%t: Pedestrian request deasserted - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Wait for pedestrian crossing to complete
        repeat(15) @(posedge clk);
        $display("Time=%t: After pedestrian crossing - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Test 4: Emergency (synchronous)
        @(posedge clk);
        emergency = 1;
        $display("Time=%t: Emergency asserted - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        repeat(5) @(posedge clk);
        $display("Time=%t: Emergency active - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Test 5: End emergency (synchronous)
        @(posedge clk);
        emergency = 0;
        $display("Time=%t: Emergency deasserted - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        repeat(5) @(posedge clk);
        $display("Time=%t: After emergency ended - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Test 6: Test pedestrian request during GREEN state (should be ignored)
        // Wait for GREEN state
        wait(ns_lights == 2'b01 || ew_lights == 2'b01);
        @(posedge clk);
        
        pedestrian_req = 1;
        $display("Time=%t: Pedestrian request in GREEN state (should be ignored) - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        @(posedge clk);
        pedestrian_req = 0;
        
        repeat(5) @(posedge clk);
        $display("Time=%t: After invalid pedestrian request - NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                 $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                 ped_walk, emergency_active);
        
        // Finish simulation
        repeat(10) @(posedge clk);
        $display("Time=%t: Test completed", $time);
        $finish;
    end
    
    // Monitor to display state changes (only when there's an actual change)
    logic [1:0] prev_ns_lights = 2'b00;
    logic [1:0] prev_ew_lights = 2'b00;
    logic       prev_ped_walk = 0;
    logic       prev_emergency_active = 0;
    
    always @(posedge clk) begin
        if (rst_n && (ns_lights != prev_ns_lights || ew_lights != prev_ew_lights || 
                     ped_walk != prev_ped_walk || emergency_active != prev_emergency_active)) begin
            $display("State Change - Time=%t: NS=%s, EW=%s, Ped=%b, Emerg=%b", 
                     $time, light_to_string(ns_lights), light_to_string(ew_lights), 
                     ped_walk, emergency_active);
        end
        
        prev_ns_lights <= ns_lights;
        prev_ew_lights <= ew_lights;
        prev_ped_walk <= ped_walk;
        prev_emergency_active <= emergency_active;
    end

endmodule

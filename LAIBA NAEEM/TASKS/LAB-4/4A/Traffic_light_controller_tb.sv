module traffic_controller_tb();
     logic       clk;         // 1 Hz
     logic       rst_n;
     logic       emergency;
     logic       pedestrian_req;
     logic [1:0] ns_lights;     // [Red, Yellow, Green]
     logic [1:0] ew_lights;
     logic       ped_walk;
     logic       emergency_active;
     logic [4:0] counter;
traffic_controller uut(.*);

initial clk = 0;
always #5 clk = ~clk;

initial begin
        rst_n = 0;
        pedestrian_req = 0;
        emergency = 0;
        @(posedge clk)
        rst_n = 1;
        pedestrian_req = 0;
        emergency = 0;
        repeat(50) begin
        @(posedge clk);
         $display("ns_lights = %d ew_lights = %d ped_walk = %d emergency_active = %d",ns_lights,ew_lights,ped_walk,emergency_active);
        end
        emergency = 1;
        pedestrian_req = 1;
        repeat(50) begin
         @(posedge clk);
         $display("ns_lights = %d ew_lights = %d ped_walk = %d emergency_active = %d",ns_lights,ew_lights,ped_walk,emergency_active);
        end
        emergency = 1;
        pedestrian_req = 0;
         repeat(50) begin
         @(posedge clk);
         $display("ns_lights = %d ew_lights = %d ped_walk = %d emergency_active = %d",ns_lights,ew_lights,ped_walk,emergency_active);
        end
end
endmodule
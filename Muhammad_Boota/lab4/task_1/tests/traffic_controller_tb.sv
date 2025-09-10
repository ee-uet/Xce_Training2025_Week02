`timescale 1ns / 1ns
import pkg::*;
module traffic_controller_tb #(TEST=100)();
logic clk;
// 1 Hz
logic rst_n;
logic emergency;
logic pedestrian_req;
traffic_lights ns_lights; // [Red, Yellow, Green]
traffic_lights ew_lights;
logic ped_walk;
logic emergency_active;

traffic_controller Traffic_Controller(
    .*
);

initial begin
    clk = 1'b0;
    forever begin
        #500000000 clk = ~clk; // Toggle every 500,000,000 ns (0.5 s) for 1 Hz
    end
end
initial begin
    rst_n=1'b1;
    emergency=1'b0;
    pedestrian_req=1'b0;
    @(posedge clk);
    rst_n=0;
    @(posedge clk);
    rst_n=1'b1;
    for (int i =0 ;i<TEST ;i++ ) begin
        emergency=$urandom_range(0,1);
        pedestrian_req=$urandom_range(0,1);
        @(posedge clk);
        repeat(80)begin
           @(posedge clk);
           $display("emergency:%d,pedestrian_req=%d \nns_lights:%s,ew_lights:%s,ped_walk:%d,emergency_active:%d",emergency,pedestrian_req,ns_lights,ew_lights,ped_walk,emergency_active); 
        end
        emergency=~emergency;
        pedestrian_req=~pedestrian_req;
        @(posedge clk);
        repeat(80)begin
           @(posedge clk);
           $display("emergency:%d,pedestrian_req=%d \nns_lights:%s,ew_lights:%s,ped_walk:%d,emergency_active:%d",emergency,pedestrian_req,ns_lights,ew_lights,ped_walk,emergency_active); 
        end
    end
    $stop;
end
endmodule
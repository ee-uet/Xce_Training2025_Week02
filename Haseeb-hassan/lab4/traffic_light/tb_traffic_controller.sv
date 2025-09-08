`timescale 1ns/1ps

module tb_traffic_controller;

  logic clk;
  logic rst_n;
  logic emergency;
  logic pedestrian_req;
  logic [1:0] ns_lights;
  logic [1:0] ew_lights;
  logic ped_walk;
  logic emergency_active;

  // Clock generation (10ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT instantiation
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

  // Test sequence
  initial begin
    rst_n = 0;
    emergency = 0;
    pedestrian_req = 0;

    #20 rst_n = 1;         // release reset

    // Normal operation
    #500;

    // Pedestrian request
    pedestrian_req = 1;
    #200;
    pedestrian_req = 0;

    // Emergency
    emergency = 1;
    #200;
    emergency = 0;

    // Run more cycles
    #500;

    $finish;
  end

endmodule

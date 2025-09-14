module traffic_fsm_tb;

logic       clk;
logic       reset_n;
logic [1:0] emerg_async;
logic       ped_request_async;
logic [1:0] ns_light;
logic [1:0] ew_light;
logic       ped_walk;
logic       flash_enable;

traffic_fsm traffic_controller(    
.clk(clk),
.reset_n(reset_n),
.emerg_async(emerg_async),
.ped_request_async(ped_request_async),
.ns_light(ns_light),
.ew_light(ew_light),
.ped_walk(ped_walk),
.flash_enable(flash_enable)
);


initial begin
    clk = 0;    
end
always #5 clk = ~clk;

initial begin
    reset_n = 1'b0;
    emerg_async = 1'b0;
    ped_request_async = 1'b0;
    #10
    reset_n = 1'b1;
    //normal operation
    #(5*10);
    #(30*10);
    #(5*10);
    #(30*10);
    #(5*10);
    #(30*10);

    //emergency
    #(5*10);
    emerg_async = 2'b11;
    #100;
    emerg_async = 2'b00;
    #(30*10);
    #(5*10);
    #(30*10);
    #(5*10);
    #(30*10);

    #10;
    reset_n = 1'b0;
    #10;
    reset_n = 1'b1;
    #(5*10);
    #(2*10);
    ped_request_async = 1'b1;
    #(30*10);


    $stop;

end

endmodule
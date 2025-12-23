`timescale 1ns/1ps
// programmable_counter_tb
module Programmable_Counter_tb;

    logic        clk;
    logic        rst_n;
    logic        load;
    logic        enable;
    logic        up_down;
    logic [7:0]  load_value;
    logic [7:0]  max_count;
    logic [7:0]  count;
    logic        terminal_count;
    logic        zero;

    Programmable_Counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .enable(enable),
        .up_down(up_down),
        .load_value(load_value),
        .max_count(max_count),
        .count(count),
        .terminal_count(terminal_count),
        .zero(zero)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    
    initial begin
        rst_n      = 0;
        load       = 0;
        enable     = 0;
        up_down    = 1;      // start with UP
        load_value = 8'd0;
        max_count  = 8'd5;   // small limit 

        // Reset
        #10;
        rst_n = 1;   // release reset
        #10;

        // Test load
        load_value = 8'd2;
        load       = 1;
        #10;
        load       = 0;

        // Test count up
        enable     = 1;
        up_down    = 1;   // UP
        #20;  
		max_count  = 8'd8;
        // Test count down
        up_down    = 0;   // DOWN
        #60;  

        // Test load again
        load_value = 8'd7;
        load       = 1;
        #10;
        load       = 0;
        #20;

        $finish;
    end

endmodule

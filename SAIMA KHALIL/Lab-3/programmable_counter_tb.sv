module programmable_counter_tb;
    // Testbench signals
    logic clk;
    logic rst_n;
    logic load;
    logic up_down;
    logic enable;
    logic [7:0] load_value;
    logic [7:0] max_count;
    logic [7:0] count;
    logic tc;
    logic zero;


    programmable_counter dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;  

 
    initial begin
       
    rst_n = 1; load = 0; enable = 0; up_down = 0; load_value = 8'd0; max_count = 8'd10;
    #12 rst_n = 0;  

     
        load = 1; load_value = 8'd5; #10;
        load = 0;

        
        enable = 1; up_down = 1; max_count = 8'd10;
        #100;
 
        enable = 0; #30;
 
        enable = 1; up_down = 0; #100;

  
        load = 1; load_value = 8'd8; #10;
        load = 0;

        enable = 1; up_down = 1; #100;

        $finish;
    end

endmodule

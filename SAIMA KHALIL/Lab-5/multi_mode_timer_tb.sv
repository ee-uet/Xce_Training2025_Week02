 
module multi_mode_timer_tb;
    logic        clk;
    logic        rst_n;
    logic [1:0]  mode;
    logic [15:0] prescaler;
    logic [31:0] reload_val;
    logic [31:0] compare_val;
    logic        start;
    logic        pwm_out;
    logic        timeout;
    logic [31:0] current_count;

   
    initial clk = 0;
    always #5 clk = ~clk;
 
    multi_mode_timer dut (.*);

    initial begin
         
        rst_n       = 0;
        mode        = 2'b00;
        prescaler   = 16'd2;      // slowign down for simulation
        reload_val  = 32'd5;
        compare_val = 32'd2;
        start       = 0;
 
        #20 rst_n = 1;

        // Test ONE_SHOT
        mode = 2'b01;
        #10 start = 1; #10 start = 0;  // single pulse
        repeat(20) @(posedge clk);
   
        // Test PERIODIC
        mode = 2'b10;
        #10 start = 1; #10 start = 0;
        repeat(40) @(posedge clk);  

        // Test PWM
        mode        = 2'b11;
        reload_val  = 32'd10;  // PWM period
        compare_val = 32'd4;   // duty cycle threshold
        #10 start = 1; #10 start = 0;
        repeat(60) @(posedge clk);

        $finish;
    end


endmodule

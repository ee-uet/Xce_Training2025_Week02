import pkg::*;
module multi_mode_timer_tb #(TESTS=1000) ();
logic clk;
logic rst_n;
timer_mode mode;
logic [15:0] prescaler; // Clock divider
logic [31:0] reload_val;
logic [31:0] compare_val; // For PWM duty cycle
logic start;
logic timeout;
logic pwm_out;
logic [31:0] current_count;

multi_mode_timer Multi_Mode_Timer (
    .*
);
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end

initial begin
    rst_n=0;
    mode=OFF;
    prescaler=0;reload_val=0;compare_val=0;
    start=0;
    #20;
    rst_n=1;
    @(posedge clk);
    for (int i = 0;i<TESTS ;i++ ) begin
        mode=timer_mode'($urandom_range(0,3));
        prescaler=$urandom_range(0,50);
        reload_val=$urandom_range(0,200);
        compare_val=$urandom%reload_val;
        start=1;
        $display("mode:%s,prescale:%d,reload_val:%d,compare_value:%d\ntimeout:%d,pwm_out:%d,current_count:%d",mode,prescaler,reload_val,compare_val,timeout,pwm_out,current_count); 
        @(posedge(clk));
        repeat(4*prescaler*reload_val)begin
            $display("mode:%s,prescale:%d,reload_val:%d,compare_value:%d\ntimeout:%d,pwm_out:%d,current_count:%d",mode,prescaler,reload_val,compare_val,timeout,pwm_out,current_count);
            @(posedge (clk));  
        end
        
    end
    start=0;
    @(posedge clk);
    $stop;
end
endmodule
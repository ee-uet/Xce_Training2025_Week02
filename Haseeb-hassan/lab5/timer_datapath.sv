module timer_datapath (
    input  logic        clk,         // 1 MHz
    input  logic        rst_n,
    input  logic [1:0]  mode,        // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,   // Clock divider
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val, // For PWM duty cycle
    input  logic        start,
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);


    
    logic [15:0] prescaler_cnt;     // counts up to prescaler value
    logic        prescaler_tick;    // 1-cycle pulse when prescaler hits target
    logic [31:0] counter;           
    logic        running;           // flag when timer is active
        
always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler_cnt  <= 16'd0;
            prescaler_tick <= 1'b0;
        end 
        else begin
            if (running) begin
                if (prescaler_cnt == prescaler) begin
                    prescaler_cnt  <= 16'd0;
                    prescaler_tick <= 1'b1;   
                end 
                else begin
                    prescaler_cnt  <= prescaler_cnt + 1;
                    prescaler_tick <= 1'b0;
                end
            end 
            else begin
                prescaler_cnt  <= 16'd0;
                prescaler_tick <= 1'b0;
            end
        end
end
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter   <= 32'd0;
        running   <= 1'b0;
        timeout   <= 1'b0;
    end
    else begin
        timeout <= 1'b0;  

        if (start && !running) begin
            counter <= reload_val;
            running <= 1'b1;
        end
        else if (running && prescaler_tick) begin
            if (counter > 0) begin
                counter <= counter - 1;
            end

            if (counter == 1) begin  // will become 0 next cycle
                case (mode)
                    2'b01: begin         // One-shot
                        running <= 1'b0;
                        timeout <= 1'b1;
                    end
                    2'b10: begin         // Periodic
                        counter <= reload_val;
                        timeout <= 1'b1;
                    end
                    2'b11: begin         // PWM
                        counter <= reload_val;
                        timeout <= 1'b0;
                    end
                    default: ;           // mode 00: off, do nothing
                endcase
            end
        end
    end
end
 always_comb begin
    pwm_out = 1'b0;  

    if (mode == 2'b11 && running) begin
        if (counter > (reload_val - compare_val))
            pwm_out = 1'b1;//, if reload_val = 100 and compare_val = 30 (30% duty cycle):
        else
            pwm_out = 1'b0;
    end
end

assign current_count = counter;


    // TO: Implement timer with all modes
    // Consider: How to handle mode changes during operation?
    
endmodule



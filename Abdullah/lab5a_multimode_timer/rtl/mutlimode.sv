module multimode(
    input  logic        clk,         // 1 mhz clock
    input  logic        rst_n,
    input  logic [1:0]  mode,        // 00=off, 01=one-shot, 10=periodic, 11=pwm
    input  logic [15:0] prescaler,   // clock divider value
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val, // for pwm duty cycle control
    input  logic        start,
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);

    logic tick;              // drives main counter on prescaler completion
    logic [15:0] psc_cnt;    // prescaler counter
    
    // prescaler logic: generates a tick based on prescaler value
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            psc_cnt <= 16'b0; 
            tick <= 1'b0; // reset prescaler and tick
        end
        else if (start) begin
            if (psc_cnt >= prescaler) begin
                psc_cnt <= 16'b0;
                tick <= 1'b1; // generate tick when prescaler count is reached
            end
            else begin
                psc_cnt <= psc_cnt + 1;
                tick <= 1'b0; // increment prescaler, no tick
            end
        end
        else begin
            psc_cnt <= 16'b0;
            tick <= 1'b0; // stop prescaler when not started
        end
    end
    
    // main timer counter logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            current_count <= reload_val; // initialize counter with reload value
        end
        else if (start) begin
            if (tick) begin
                case (mode) 
                    // mode 00: timer off
                    2'b00: begin
                        current_count <= 32'b0; // counter stays at 0
                    end
                        
                    // mode 01: one-shot
                    // counts down once, then stays at 0
                    2'b01: begin
                        if (current_count == 32'b0) begin
                            current_count <= 32'b0; // hold at 0 after countdown
                        end
                        else begin
                            current_count <= current_count - 1; // decrement counter
                        end
                    end
                
                    // mode 10: periodic
                    // reloads automatically after reaching 0
                    2'b10: begin
                        if (current_count == 32'b0) begin
                            current_count <= reload_val; // reload counter
                        end
                        else begin
                            current_count <= current_count - 1; // decrement counter
                        end
                    end
                        
                    // mode 11: pwm
                    // drives pwm output, reloads at 0
                    2'b11: begin
                        if (current_count == 32'b0) begin
                            current_count <= reload_val; // reload counter
                        end
                        else begin
                            current_count <= current_count - 1; // decrement counter
                        end
                    end
                    default: begin
                        current_count <= current_count; // maintain current count
                    end
                endcase    
            end
            else begin
                current_count <= current_count; // hold count when no tick
            end
        end
        else begin
            current_count <= current_count; // hold count when not started
        end
    end    
    
    // pwm output: high when current_count <= compare_val in pwm mode
    assign pwm_out = ((mode == 2'b11) && (current_count <= compare_val));
    
    // timeout flag: asserted when counter reaches 0 in non-off mode
    assign timeout = ((mode != 2'b00) && (current_count == 32'b0));
    
endmodule
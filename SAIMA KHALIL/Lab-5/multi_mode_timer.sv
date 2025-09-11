module multi_mode_timer (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  mode,         // 00=OFF, 01=ONE_SHOT, 10=PERIODIC, 11=PWM
    input  logic [15:0] prescaler,    // Clock divider
    input  logic [31:0] reload_val,   // Timer start value
    input  logic [31:0] compare_val,  // PWM duty cycle
    input  logic        start,        // Start timer
    output logic        pwm_out,
    output logic        timeout,
    output logic [31:0] current_count
); 
    logic [15:0] prescaler_count;
    logic [31:0] count;
    logic        running;

    
    // Start edge detect
    logic start_d;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            start_d <= 0;
        else
            start_d <= start;
    end
    wire start_pulse = start & ~start_d;  // rising edge detect
 
    // Main counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count           <= 0;
            prescaler_count <= 0;
            running         <= 0;
            timeout         <= 0;
        end else begin
            // default
            timeout <= 0;

            // if Start pulse  load timer
            if (start_pulse && mode != 2'b00) begin
                running         <= 1;
                count           <= reload_val;
                prescaler_count <= 0;
                timeout         <= 0;
            end

            // If running → decrement
            if (running) begin
                if (prescaler_count == prescaler-1) begin
                    prescaler_count <= 0;

                    if (count > 0) begin
                        count <= count - 1;
                    end else begin
                        // count == 0
                        timeout <= 1;  // 1-cycle pulse
                        case (mode)
                            2'b01: running <= 0;          // ONE_SHOT
                            2'b10: count   <= reload_val; // PERIODIC
                            2'b11: count   <= reload_val; // PWM
                            default: running <= 0;
                        endcase
                    end
                end else begin
                    prescaler_count <= prescaler_count + 1;
                end
            end
        end
    end

     
    // PWM logic
    always_comb begin
        if (mode == 2'b11 && running)
            pwm_out = (count > compare_val);
        else
            pwm_out = 0;
    end

 
    // Current count output
    assign current_count = count;

endmodule

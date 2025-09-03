module   top_timer (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  mode,         // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,    // Clock divider
    input  logic [31:0] reload_val,
    input  logic [31:0] compare_val,  // For PWM duty cycle
    input  logic        start,        // External start
    output logic        timeout,
    output logic        pwm_out,
    output logic [31:0] current_count
);

    
    logic prescaler_enable;
    logic cnt_load;
    logic cnt_enable;
    logic cnt_reload_on_zero;
    logic counter_zero;

    
    logic [31:0] counter_internal;
    timer_datapath U_DATAPATH (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .prescaler(prescaler),
        .reload_val(reload_val),
        .compare_val(compare_val),
        .start(cnt_load),
        .timeout(timeout),
        .pwm_out(pwm_out),
        .current_count(counter_internal)
    );

    assign current_count = counter_internal;
    assign counter_zero = (counter_internal == 32'd0);

    
    timer_fsm U_FSM (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .counter_zero(counter_zero),
        .mode(mode),
        .prescaler_enable(prescaler_enable),
        .cnt_load(cnt_load),
        .cnt_enable(cnt_enable),
        .cnt_reload_on_zero(cnt_reload_on_zero)
    );

endmodule

module Top (
    input   logic        clk,
    input   logic        reset_n,
    input   logic        start,
    input   logic [1:0]  mode,
    input   logic [15:0] prescale_val,
    input   logic [31:0] reload_value,
    input   logic [31:0] compare_value,
    output  logic        time_out,
    output  logic        pwm_out
);

    logic           prescaled_clk;
    logic           enable;
    logic           reload_signal;
    logic           pwm_signal;
    logic [31:0]    current_count;
    logic           one_shot;
    logic           periodic;
    logic           pwm_mode;
    logic           off_signal;

    // Prescaler
    Clk_Gen_Prescaler u_prescaler (
        .clk            (clk),
        .reset_n        (reset_n),
        .prescale_val   (prescale_val),
        .prescaled_clk  (prescaled_clk)
    );

    // Countdown
    CountDown u_counter (
        .prescaled_clk  (prescaled_clk),
        .reset_n        (reset_n),       // <-- fixed
        .enable         (enable),
        .reload_signal  (reload_signal),
        .pwm_signal     (pwm_signal),
        .reload_value   (reload_value),  // <-- fixed typo
        .compare_value  (compare_value),
        .current_count  (current_count)
    );

    // Comparator
    LogicComparater u_compare (
        .current_count  (current_count),
        .compare_value  (compare_value),
        .mode           (mode),
        .one_shot       (one_shot),
        .periodic       (periodic),
        .pwm_mode       (pwm_mode),
        .off_signal     (off_signal)
    );

    // FSM
    CountFSM u_fsm (
        .prescaled_clk  (prescaled_clk),
        .reset_n        (reset_n),
        .start          (start),
        .one_shot       (one_shot),
        .periodic       (periodic),
        .pwm_mode       (pwm_mode),
        .off_signal     (off_signal),
        .current_count  (current_count),
        .enable         (enable),
        .reload_signal  (reload_signal),
        .pwm_signal     (pwm_out),       // FSM drives pwm_out
        .timeout        (time_out)
    );

endmodule

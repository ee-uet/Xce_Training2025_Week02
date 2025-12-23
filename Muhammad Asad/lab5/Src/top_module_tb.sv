module top_module_tb;
    logic clk;
    logic reset_n;
    logic start;
    logic [1:0] mode;
    logic [15:0] prescale_val;
    logic [31:0] reload_value;
    logic [31:0] compare_value;
    logic time_out;
    logic pwn_out;
    logic prescaled_clk;

    // Instantiate Prescaler
    Prescaler prescaler_inst (
        .clk(clk),
        .reset_n(reset_n),
        .prescale_val(prescale_val),
        .prescaled_clk(prescaled_clk)
    );

    // Instantiate DUT
    top_module dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .mode(mode),
        .prescale_val(prescale_val),
        .reload_value(reload_value),
        .compare_value(compare_value),
        .time_out(time_out),
        .pwn_out(pwn_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    initial begin
        
        reset_n      = 0;
        start        = 0;
        mode         = 2'b00;
        prescale_val = 16'd2;
        reload_value = 32'd10;
        compare_value= 32'd5;
        #3
        reset_n = 1;
        // One-shot mode test
        @(posedge prescaled_clk);
        mode  = 2'b01;  start = 1;
        @(posedge prescaled_clk);
        start = 0;
        repeat (6) @(posedge prescaled_clk);
        // Periodic mode test
        mode = 2'b10; start = 1;
        @(posedge prescaled_clk);
        start = 0;
        repeat (10) @(posedge prescaled_clk);

        // PWM mode test
        mode = 2'b11;
        start = 1;
        @(posedge prescaled_clk);
        start = 0;

        repeat (10) @(posedge prescaled_clk);

        // Finish simulation
        $finish;
    end
endmodule
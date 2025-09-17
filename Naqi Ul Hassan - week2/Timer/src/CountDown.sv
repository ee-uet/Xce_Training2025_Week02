module CountDown (
    input  logic         prescaled_clk,
    input  logic         reset_n,
    input  logic         enable,
    input  logic         reload_signal,
    input  logic         pwm_signal,
    input  logic [31:0]  reload_value,
    input  logic [31:0]  compare_value,
    output logic [31:0]  current_count
);

    always_ff @(posedge prescaled_clk or negedge reset_n) begin
        if (!reset_n)
            current_count <= 32'd0;
        else if (reload_signal)
            current_count <= reload_value;
        else if (pwm_signal)
            current_count <= compare_value;
        else if (enable && current_count != 0)
            current_count <= current_count - 1;
    end

endmodule

module down_counter (
    input logic         prescaled_clk,
    input logic         enable,
    input logic         relaod_signal,
    input logic         pwm_signal,
    input logic [31:0]  relaod_value,
    input logic [31:0]  compare_value,
    output logic [31:0] current_count
);
    always_ff @(posedge prescaled_clk) begin
        if (relaod_signal) begin
            current_count <= relaod_value;
        end
        else if (enable) begin
            current_count <= current_count - 1;
        end
        else if (pwm_signal) begin
            current_count <= compare_value;
        end
        else begin
            current_count <= 32'd0;
        end
    end
endmodule
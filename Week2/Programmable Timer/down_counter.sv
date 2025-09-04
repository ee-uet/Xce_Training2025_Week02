module down_counter (
    input  logic        prescaled_clk,   // Clock input
    input  logic        reset_n,         // Active-low reset
    input  logic        enable,          // Enable counting
    input  logic        reload_signal,   // Reload trigger
    input  logic [31:0] reload_value,    // Value to reload
    input  logic [31:0] compare_value,   // Compare match value (for PWM)
    output logic [31:0] current_count,   // Current counter value
    output logic        compare_match    // Asserted when count == compare_value
);

    always_ff @(posedge prescaled_clk or negedge reset_n) begin
        if (!reset_n) begin
            current_count <= 32'd0;
        end 
        else if (reload_signal) begin
            current_count <= reload_value;  
        end 
        else if (enable) begin
            if (current_count == 32'd0)
                current_count <= reload_value;  // Auto-reload when underflow
            else
                current_count <= current_count - 32'd1;
        end 
    end

    // Compare match output (used for PWM toggle logic)
    assign compare_match = (current_count == compare_value);

endmodule

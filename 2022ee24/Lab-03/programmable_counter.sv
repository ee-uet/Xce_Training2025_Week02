module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,        // Asynchronous active-low reset
    input  logic        load,         // Load count with load_value
    input  logic        enable,       // Enable counting
    input  logic        up_down,      // 0: count up, 1: count down
    input  logic [7:0]  load_value,   // Value to load into counter
    input  logic [7:0]  max_count,    // Max count (for up direction)
    output logic [7:0]  count,        // Counter output
    output logic        tc,           // Terminal count flag
    output logic        zero          // Zero detect flag
);


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'd0;
        end else if (load) begin
            count <= load_value;
        end else if (enable) begin
            if (up_down == 1'b0) begin
                if (count < max_count)
                    count <= count + 1;
            end else begin
                if (count > 8'd0)
                    count <= count - 1;
            end
        end
    end

    // Terminal Count Logic
    always_comb begin
        if (up_down == 1'b0)
            tc = (count == max_count);
        else
            tc = (count == 8'd0);  // Terminal when counting down to zero
    end

    // Zero detect
    assign zero = (count == 8'd0);

endmodule

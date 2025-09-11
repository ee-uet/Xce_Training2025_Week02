module programmable_counter (
    input  logic        clk,        
    input  logic        rst_n,      // active-low reset
    input  logic        load,       // load initial value
    input  logic        enable,     // enable counting
    input  logic        up_down,    // 1 = UP, 0 = DOWN
    input  logic [7:0]  load_value, // starting value to load
    input  logic [7:0]  max_count,  
    output logic [7:0]  count,      // current value
    output logic        tc,         // terminal count flag
    output logic        zero        // zero flag
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            tc    <= 0;
            zero  <= 1;
        end 
        else if (load) begin
            // clamp load_value to max_count if needed
            count <= (load_value > max_count) ? max_count : load_value;
            tc    <= 0; 
            zero  <= ((load_value > max_count) ? max_count : load_value) == 0;
        end 
        else if (enable) begin
            if (up_down) begin
                // UP COUNTER
                if (count < max_count) begin
                    count <= count + 1;
                    tc    <= (count + 1 == max_count);
                    zero  <= 0;
                end 
                else begin
                    count <= max_count;
                    tc    <= 1;
                    zero  <= (max_count == 0);
                end
            end 
            else begin
                // DOWN COUNTER
                if (count > 0) begin
                    count <= count - 1;
                    tc    <= (count - 1 == 0);
                    zero  <= (count - 1 == 0);
                end 
                else begin
                    count <= 0;
                    tc    <= 1;
                    zero  <= 1;
                end
            end
        end
    end

endmodule

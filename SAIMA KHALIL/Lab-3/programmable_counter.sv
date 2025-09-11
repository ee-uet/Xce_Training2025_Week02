module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load,       // 1=load value into counter
    input  logic        up_down,    // 1=up, 0=down
    input  logic        enable,     // 1=enable counting
    input  logic [7:0]  load_value, // threshold (minimum limit for down / start for up)
    input  logic [7:0]  max_count,  // maximum limit for up
    output logic [7:0]  count,
    output logic        tc,         // 1 when count == max_count (up mode)
    output logic        zero        // 1 when count == load_value (down mode)
);

    logic [7:0] count_d;

    // Sequential block
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n)
            count <= 8'd0;   // reset always to 0
        else
            count <= count_d;
    end

    // Next-state logic
    always_comb begin
        count_d = count; // default hold

        if (load) begin
            if (up_down) 
                count_d = load_value;  // UP mode: load_value is start
            else 
                count_d = 8'd0;        // DOWN mode: start from 0
        end 
        else if (enable) begin
            if (!up_down) begin
                // ----------- DOWN counter -----------
                if (count > load_value)
                    count_d = count - 1;   // decrement
                else
                    count_d = 0;  
            end 
            else begin
                // ----------- UP counter -----------
                if (count < max_count)
                    count_d = count + 1;   // increment
                else
                    count_d = load_value;  // wrap to start
            end
        end
    end

    // Flags
    assign tc   = (count == max_count);   // reached max (up mode)
    assign zero = (count == load_value);  // reached threshold (down mode)

endmodule

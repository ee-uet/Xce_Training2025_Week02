module timer (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       count_start,
    input  logic [4:0] count_value,
    output logic       count_done
);

    logic [4:0] counter;

    // ------------------------------------------------------------
    // Sequential logic: countdown timer
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter    <= 5'd0;
            count_done <= 1'b0;
        end 
        else if (count_start) begin
            if (counter == 5'd0) begin
                counter    <= count_value;  // load new value
                count_done <= (count_value == 5'd0);
            end 
            else begin
                counter    <= counter - 5'd1;
                count_done <= (counter == 5'd1);
            end
        end 
        else begin
            counter    <= count_value; // preload until start
            count_done <= 1'b0;
        end
    end

endmodule

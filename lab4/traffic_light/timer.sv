module timer (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,        // one-cycle pulse to (re)start timer
    input  logic [7:0] load_value,   // counts in clock ticks (1 Hz assumed)
    output logic       done
);

    logic [7:0] count_reg;
    logic       running;
    logic       start_d;

    // sample start to detect rising edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_d   <= 1'b0;
            running   <= 1'b0;
            count_reg <= 8'd0;
        end else begin
            start_d <= start;
            // start rising edge detection
            if (start && !start_d) begin
                count_reg <= load_value;
                running   <= (load_value != 8'd0);
            end else if (running) begin
                if (count_reg > 0)
                    count_reg <= count_reg - 1;
                else
                    running <= 1'b0;
            end
        end
    end

    always_comb begin
        done = (running == 1'b0) && (count_reg == 8'd0);
        // if not running and count 0 -> done=1
    end

endmodule

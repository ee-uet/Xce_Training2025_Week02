module Count (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       count_start,
    input  logic [4:0] count_value,
    output logic       count_done
);

    logic [4:0] counter;
    logic       active;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter     <= 5'd0;
            active      <= 1'b0;
            count_done  <= 1'b0;
        end 
        else if (count_start) begin
            counter     <= count_value;
            active      <= (count_value != 0);
            count_done  <= (count_value == 0);
        end 
        else if (active) begin
            if (counter > 0) begin
                counter     <= counter - 1;
                count_done  <= (counter == 1);
            end 
            else begin
                active      <= 1'b0;
                count_done  <= 1'b0; // stays low after done
            end
        end 
        else begin
            count_done <= 1'b0;
        end
    end

endmodule

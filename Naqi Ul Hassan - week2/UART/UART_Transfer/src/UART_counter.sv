module UART_counter (
    input  logic div_clk,
    input  logic rst_n,
    input  logic start_count,
    output logic count_done
);
    logic [3:0] current_count;

    always_ff @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            current_count <= 4'd0;
        end 
        else if (start_count) begin
            if (current_count < 4'd8)
                current_count <= current_count + 1;
        end
    end

    always_comb begin
        count_done = (current_count == 4'd8);
    end

endmodule

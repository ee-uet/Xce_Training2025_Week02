module counter (
    input logic spi_clk,
    input logic rst_n,
    input logic start_count,
    output logic count_done
    
);
logic [3:0] current_count;

always_ff @(posedge spi_clk or negedge rst_n) begin
    if (!rst_n) begin
        current_count <= 0;
        
    end else if (start_count) begin
            current_count <= current_count + 1;
            
        end
    end
    else begin
        current_count <= <4'd0;
end
always_comb begin
    if (current_count == 4'd8) begin
        count_done = 1;
    end else begin
        count_done = 0;    
    end
end


endmodule
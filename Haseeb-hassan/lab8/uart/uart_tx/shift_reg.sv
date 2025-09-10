module shift_reg (
    input logic div_clk,
    input logic [7:0] tx_data,
    input logic rst_n,
    input logic load,
    input logic start_shift,
    input logic start,
    output logic tx_serial
);

    logic [7:0] shift_reg;

    always_ff @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'hFF;      
            tx_serial <= 1'b1;       
        end
        else if (load) begin
            shift_reg <= tx_data;     
            tx_serial <= 1'b1;       
        end 
        else if (start) begin
            tx_serial <= 1'b0;      
        end
        else if (start_shift) begin
            tx_serial <= shift_reg[0]; 
            shift_reg <= {1'b1, shift_reg[7:1]}; // Shift right, fill MSB with 1
        end
        else begin
            tx_serial <= 1'b1;       
        end
    end

endmodule
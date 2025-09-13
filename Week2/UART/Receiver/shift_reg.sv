module shift_reg (
    input logic div_clk
    input logic rx_serial,
    input logic rst_n,
    input logic start_shift,
    output logic [7:0] rx_data,
    output logic frame_error
    

);

logic [8:0] shift_reg; // 9 bits register to also store the stopping bit

always_ff @(negedge div_clk) begin //sampling at mid point 
    if (!rst_n) begin
        shift_reg <= 8'd0;
    end
    else if (start_shift) begin
        shift_reg <= {rx_serial, shift_reg[7:1]};
    end
    else begin
        rx_data <= shift_reg[7:0];
    end
    
end
always_comb begin
    frame_error = 0;
    
    if (start_check) begin
        frame_error = shift_reg[8] == 1'b0 ? 1'b1 : 1'b0; // if stop bit is not 1, frame error
    end
end

endmodule
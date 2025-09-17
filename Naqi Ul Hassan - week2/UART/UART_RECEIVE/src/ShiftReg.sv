module ShiftReg (
    input  logic        div_clk,
    input  logic        rx_serial,
    input  logic        rst_n,
    input  logic        start_shift,
    input  logic        start_check,
    output logic [7:0]  rx_data,
    output logic        frame_error
);

    logic [8:0] shift_reg;

    // Shift in data at each baud tick (negative edge)
    always_ff @(negedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 9'd0;
            rx_data   <= 8'd0;
        end
        else if (start_shift) begin
            shift_reg <= {rx_serial, shift_reg[8:1]}; // Shift in new bit
        end
        else if (!start_shift && start_check) begin
            rx_data <= shift_reg[7:0];                // Latch received byte
        end
    end

    // Frame error detection: stop bit should be 1
    always_comb begin
        if (start_check) begin
            frame_error = (shift_reg[8] == 1'b0);
        end else begin
            frame_error = 1'b0;
        end
    end

endmodule

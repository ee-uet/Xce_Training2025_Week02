module ShiftReg (
    input  logic       div_clk,
    input  logic [7:0] tx_data,
    input  logic       rst_n,
    input  logic       load,        // load parallel data
    input  logic       start_shift, // enable shifting
    input  logic       start,       // send start bit
    output logic       tx_serial
);

    logic [7:0] shreg;  // renamed to avoid clash
    logic       sending; 

    always_ff @(posedge div_clk or negedge rst_n) begin
        if (!rst_n) begin
            shreg     <= 8'd0;
            tx_serial <= 1'b1;  // idle state
            sending   <= 1'b0;
        end 
        else if (load) begin
            shreg   <= tx_data; // load new data
            sending <= 1'b0;
        end 
        else if (start) begin
            tx_serial <= 1'b0;  // start bit
            sending   <= 1'b1;
        end
        else if (sending && start_shift) begin
            tx_serial <= shreg[0];     // output LSB
            shreg     <= shreg >> 1;   // shift right
        end
        else begin
            tx_serial <= 1'b1;  // idle or stop bit
        end
    end

endmodule

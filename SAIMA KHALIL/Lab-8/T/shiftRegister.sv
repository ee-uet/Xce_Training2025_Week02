module shiftRegister(
    input  logic       baud_clk,
    input  logic       reset,
    input  logic [7:0] data,
    input  logic       s_load,  
    input  logic       s_shift,      
    output logic       s_empty,
    output logic [3:0] count_q,
    output logic       tx_serial
); 
    logic [9:0] shiftRegister;

    always_ff @(posedge baud_clk or posedge reset) begin
    if (reset) begin
        shiftRegister <= 10'b1111111111; // idle high
        s_empty       <= 1;
        count_q       <= 0;
        tx_serial     <= 1;
    end 
    else if (s_load) begin
        shiftRegister <= {1'b1, data, 1'b0}; // stop, data, start
        s_empty       <= 0;
        count_q       <= 0;
    end 
    else if (s_shift) begin
        tx_serial     <= shiftRegister[0];
        shiftRegister <= shiftRegister >> 1;
        count_q       <= count_q + 1;
        if (count_q == 10) s_empty <= 1; // after last stop bit
    end
end

endmodule

module PriorityEncoder823_m_tb;

    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;

    PriortyEncoder823_m dut(
        .enable         (enable),
        .data_in        (data_in),
        .encoded_out    (encoded_out),
        .valid          (valid)
    );
    
    initial begin
        enable = 0; data_in = 8'b10101010; #10
        enable = 1; data_in = 8'b00010000; #10
        enable = 1; data_in = 8'b01011000; #10
        enable = 1; data_in = 8'b00000000; #10
        $finish;
    end

endmodule

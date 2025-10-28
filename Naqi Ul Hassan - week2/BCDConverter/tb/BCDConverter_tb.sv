module BCDConverter_tb;

    logic [7:0]  binary_in;
    logic [11:0] bcd;

    BCDConverter uut (
        .binary_in  (binary_in),
        .bcd        (bcd)
    );

    initial begin
        binary_in = 8'd0;   #10
        binary_in = 8'd6;   #10
        binary_in = 8'd32;  #10
        binary_in = 8'd164; #10
        $finish;
    end

endmodule

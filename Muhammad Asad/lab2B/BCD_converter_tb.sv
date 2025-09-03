module BCD_converter_tb;
    logic [7:0] binary_in;
    logic [11:0] bcd;

    BCD_converter uut (
        .binary_in(binary_in),
        .bcd(bcd)
    );

    initial begin
        
        binary_in = 8'd0;
        #5;
        binary_in = 8'd9;
        #5;
        binary_in = 8'd45;
        #5;
        binary_in = 8'd123;
        #5;

        $finish;
    end
endmodule
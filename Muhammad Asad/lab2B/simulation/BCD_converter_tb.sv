module BCD_converter_tb;
    logic [7:0] binary_in;
    logic [11:0] bcd;

    BCD_converter uut (
        .binary_in(binary_in),
        .bcd(bcd)
    );

    initial begin
        // Testing one digit decimal
        binary_in = 8'd9;
        #10;
        // Testing two digit decimal
        binary_in = 8'd45;
        #10;
        // Testing 3 digit decimal
        binary_in = 8'd123;
        #10;

        $finish;
    end
endmodule
module bcd_comb_tb;

    // DUT signals
    logic [7:0] data_in;
    logic [3:0] bcd_out1, bcd_out2, bcd_out3;

    // Instantiate DUT
    bcd_comb dut (
        .data_in(data_in),
        .bcd_out1(bcd_out1),
        .bcd_out2(bcd_out2),
        .bcd_out3(bcd_out3)
    );

    // Task to display results
    task check(input [7:0] value);
        begin
            data_in = value;
            #5; // wait for outputs to settle
            $display("Binary: %0b  -->  BCD: %0d%0d%0d",
                     data_in, bcd_out3, bcd_out2, bcd_out1);
        end
    endtask

    initial begin
        $display("==== Binary to BCD Test ====");

        // Apply some test values
        check(8'd0);      // expect 000
        check(8'd5);      // expect 005
        check(8'd9);      // expect 009
        check(8'd12);     // expect 012
        check(8'd45);     // expect 045
        check(8'd99);     // expect 099
        check(8'd123);    // expect 123
        check(8'd200);    // expect 200
        check(8'd255);    // expect 255

        $display("==== Test Completed ====");
        $finish;
    end

endmodule


module binary_to_bcd_tb;
    logic [7:0]  binary_in;
    logic [11:0] bcd_out;

    binary_to_bcd dut (
        .binary_in(binary_in),
        .bcd_out(bcd_out)
    );

    initial begin
        // Test multiple values
        logic [7:0] test_vals [0:4] = '{0, 1, 50, 99, 255};
        int idx;

        for (idx = 0; idx < 5; idx++) begin
            binary_in = test_vals[idx];
            #1;
            $display("binary_in = %0d (%b)", binary_in, binary_in);
            $display("bcd_out   = %b", bcd_out);
            $display("Hundreds  = %0d", bcd_out[11:8]);
            $display("Tens      = %0d", bcd_out[7:4]);
            $display("Ones      = %0d\n", bcd_out[3:0]);
        end

        $finish;
    end
endmodule

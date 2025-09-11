module tb_binary_to_bcd;
    logic [7:0] binary_in;
    logic [11:0] bcd_out;

    binary_to_bcd uut (
        .binary_in(binary_in),
        .bcd_out(bcd_out)
    );

    logic [7:0] test_values [0:7];

    initial begin
        // Initialize test values
        test_values[0] = 0;
        test_values[1] = 1;
        test_values[2] = 12;
        test_values[3] = 13;
        test_values[4] = 45;
        test_values[5] = 99;
        test_values[6] = 128;
        test_values[7] = 202;

        $display("Binary to BCD Conversion Testbench");
        $display("Binary  | Decimal | BCD Out [H T O]");

        foreach (test_values[i]) begin
            binary_in = test_values[i];
            #1; // Delay for combinational logic
            $display("%3d      | %3d     | %b_%b_%b",
                     binary_in,
                     binary_in,
                     bcd_out[11:8], // hundreds
                     bcd_out[7:4],  // tens
                     bcd_out[3:0]); // ones
        end

        $stop;
    end
endmodule

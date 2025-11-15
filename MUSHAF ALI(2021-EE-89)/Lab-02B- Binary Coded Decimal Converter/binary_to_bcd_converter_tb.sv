`timescale 1ns/1ps

module tb_bin_to_bcd;

    // Testbench signals
    logic [7:0] bin;
    logic [11:0] bcd;

    // Instantiate DUT
    bin_to_bcd dut (
        .bin(bin),
        .bcd(bcd)
    );

    // Task to display BCD result as decimal
    task display_bcd(input [11:0] bcd_val);
        logic [3:0] hundreds, tens, units;
        begin
            hundreds = bcd_val[11:8];
            tens     = bcd_val[7:4];
            units    = bcd_val[3:0];
            $display("BCD = %0d%0d%0d", hundreds, tens, units);
        end
    endtask

    // Stimulus
    initial begin
        $display("---- Binary to BCD Conversion Testbench ----");

        // Test a few cases
        bin = 8'd0;   #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd5;   #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd12;  #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd45;  #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd99;  #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd123; #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);
        bin = 8'd255; #5; $display("BIN=%0d -> ", bin); display_bcd(bcd);

        $display("---- Test Completed ----");
        $stop;
    end

endmodule

module binary_to_bcd_tb();
    logic [7:0]  binary_in;
    logic [11:0] bcd_out;

    binary_to_bcd uut(.*);

    initial begin
        binary_in = 8'b11100110; // 230 decimal
        #2; // wait for combinational output to settle
       $display("BCD: %0d %0d %0d", bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);

    end
endmodule

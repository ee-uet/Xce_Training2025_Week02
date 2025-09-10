module binary_to_bcd_tb #(TESTS=1000) ();
    logic [7:0]  binary_in;
    logic [11:0] bcd_out;

    binary_to_bcd BCD(
        .*
    ) ;
    logic clk;
    initial begin
        clk=0;
        forever #1 clk=~clk;
    end

    initial begin
        for ( int i=0 ;i<TESTS ;i++ ) begin
            binary_in=$urandom_range(-128,127);
            @(posedge clk)
            $display("BCD of %h is %h %h %h",binary_in,bcd_out[11:8],bcd_out[7:4],bcd_out[3:0]);
        end
        $finish;
    end
endmodule
import pkg::*;
module barrel_shifter_tb #(TESTS=1000)();
    logic [31:0] data_in;    
    logic [4:0] shift_amt;
    direction left_right;
    mode shift_rotate   ;
    logic [31:0] data_out;
    logic clk;
    barrel_shifter barrel_shifter(
        .*
    );

    initial begin
        clk=0;
        forever #1 clk=~clk;
    end

    initial begin
        for (int i =0 ;i<TESTS ;i++ ) begin
            data_in=$random;
            shift_amt=$urandom_range(0,31);
            left_right= direction'($urandom_range(0,1));
            shift_rotate=mode'($urandom_range(0,1));
            @(posedge clk);
            $display("number:%b %s %s by %d amount ,ans=%b",data_in,shift_rotate,left_right,shift_amt,data_out);
        end
        $finish;
    end

endmodule
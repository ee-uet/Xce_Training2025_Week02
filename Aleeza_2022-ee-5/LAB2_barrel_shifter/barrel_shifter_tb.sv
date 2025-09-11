module barrel_shifter_tb;

    logic [31:0] D;
    logic [4:0]  shift;
    logic dir;
    logic mode;
    logic [31:0] Y;

    barrel_shifter dut (
        .D(D),
        .shift(shift),
        .dir(dir),
        .mode(mode),
        .Y(Y)
    );

    initial begin
        $display("==== 32-bit Barrel Shifter Test ====");

        // Test 1: Shift left logical
        D = 32'h0000_F0F0; shift = 5'd4; dir = 0; mode = 0; #5;
        $display("Shift L, SLL: D=%h shift=%d --> Y=%h", D, shift, Y);

        // Test 2: Shift right logical
        D = 32'hF0F0_0000; shift = 5'd8; dir = 1; mode = 0; #5;
        $display("Shift R, SLL: D=%h shift=%d --> Y=%h", D, shift, Y);

        // Test 3: Rotate left
        D = 32'h1234_5678; shift = 5'd8; dir = 0; mode = 1; #5;
        $display("Rotate L: D=%h shift=%d --> Y=%h", D, shift, Y);

        // Test 4: Rotate right
        D = 32'h1234_5678; shift = 5'd12; dir = 1; mode = 1; #5;
        $display("Rotate R: D=%h shift=%d --> Y=%h", D, shift, Y);

        $display("==== Test Completed ====");
        $finish;
    end

endmodule


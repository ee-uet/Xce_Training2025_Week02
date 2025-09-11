`timescale 1ns/1ps

module barrel_shifter_tb;

    // DUT signals
    logic [31:0] data_in;
    logic [4:0]  shift_amt;
    logic        left_right;
    logic        shift_rotate;
    logic [31:0] data_out;

    // Instantiate DUT
    barrel_shifter dut (
        .data_in(data_in),
        .shift_amt(shift_amt),
        .left_right(left_right),
        .shift_rotate(shift_rotate),
        .data_out(data_out)
    );

    // Task for self-checking tests
    task run_test(input [31:0] din,
                  input [4:0]  amt,
                  input        lr,
                  input        rot,
                  input [31:0] expected);
        begin
            data_in      = din;
            shift_amt    = amt;
            left_right   = lr;
            shift_rotate = rot;
            #1; // wait for combinational settle

            if (data_out === expected) begin
                $display("PASS: IN=%h, shift_amt=%0d, %s %s => OUT=%h",
                          data_in, shift_amt,
                          (left_right ? "RIGHT" : "LEFT"),
                          (shift_rotate ? "ROTATE" : "SHIFT"),
                          data_out);
            end else begin
                $display("FAIL: IN=%h, shift_amt=%0d, %s %s => OUT=%h (expected %h)",
                          data_in, shift_amt,
                          (left_right ? "RIGHT" : "LEFT"),
                          (shift_rotate ? "ROTATE" : "SHIFT"),
                          data_out, expected);
            end
        end
    endtask

    initial begin
        $display("==== Barrel Shifter Testbench ====");

        // ---- Shift Left ----
        run_test(32'hA5A5_A5A5, 5'd0, 0, 0, 32'hA5A5A5A5);
        run_test(32'hA5A5_A5A5, 5'd1, 0, 0, 32'h4B4B4B4A);
        run_test(32'hA5A5_A5A5, 5'd4, 0, 0, 32'h5A5A5A50);
        run_test(32'hA5A5_A5A5, 5'd8, 0, 0, 32'hA5A5A500);
        run_test(32'hA5A5_A5A5, 5'd16,0, 0, 32'hA5A50000);

        // ---- Shift Right ----
        run_test(32'hA5A5_A5A5, 5'd1, 1, 0, 32'h52D2D2D2);
        run_test(32'hA5A5_A5A5, 5'd4, 1, 0, 32'h0A5A5A5A);
        run_test(32'hA5A5_A5A5, 5'd8, 1, 0, 32'h00A5A5A5);
        run_test(32'hA5A5_A5A5, 5'd16,1, 0, 32'h0000A5A5);

        // ---- Rotate Left ----
        run_test(32'hDEAD_BEEF, 5'd1, 0, 1, 32'hBD5B7DDF);
        run_test(32'hDEAD_BEEF, 5'd4, 0, 1, 32'hEADBEEFD);
        run_test(32'hDEAD_BEEF, 5'd8, 0, 1, 32'hADBEEFDE);

        // ---- Rotate Right ----
        run_test(32'hDEAD_BEEF, 5'd1, 1, 1, 32'hEF56DF77);
        run_test(32'hDEAD_BEEF, 5'd4, 1, 1, 32'hFDEADBEE);
        run_test(32'hDEAD_BEEF, 5'd8, 1, 1, 32'hEFDEADBE);
        run_test(32'hDEAD_BEEF, 5'd31,1, 1, 32'hBD5B7DDF);

        $display("==== Tests Completed ====");
        $finish;
    end

endmodule

`timescale 1ns/1ps

module tb_priority_encoder;

    // DUT signals
    logic enable;
    logic [7:0] in;
    logic [2:0] out;
    logic valid;

    // Instantiate DUT
    priority_encoder dut (
        .enable(enable),
        .in(in),
        .out(out),
        .valid(valid)
    );

    // Task to apply stimulus
    task apply_input(input logic en, input logic [7:0] din);
        begin
            enable = en;
            in     = din;
            #10;  // wait for combinational logic to settle
            $display("Time=%0t | enable=%b | in=%b | out=%b | valid=%b",
                     $time, enable, in, out, valid);
        end
    endtask

    initial begin
        $display("------ Starting Priority Encoder Testbench ------");

        // Initialize
        enable = 0;
        in     = 8'b00000000;
        #5;

        // Case 1: Disabled, all inputs zero
        apply_input(0, 8'b00000000);

        // Case 2: Enabled, input = 0
        apply_input(1, 8'b00000000);

        // Case 3: One-hot inputs (check correct priority encoding)
        apply_input(1, 8'b00000001); // expect out=000, valid=1
        apply_input(1, 8'b00000010); // expect out=001, valid=1
        apply_input(1, 8'b00000100); // expect out=010, valid=1
        apply_input(1, 8'b00001000); // expect out=011, valid=1
        apply_input(1, 8'b00010000); // expect out=100, valid=1
        apply_input(1, 8'b00100000); // expect out=101, valid=1
        apply_input(1, 8'b01000000); // expect out=110, valid=1
        apply_input(1, 8'b10000000); // expect out=111, valid=1

        // Case 4: Multiple bits set (priority check)
        apply_input(1, 8'b10101010); // expect out=111 (bit7 has highest priority)
        apply_input(1, 8'b00111000); // expect out=100 (bit4 highest among 4,5,3)

        // Case 5: Disabled with some input
        apply_input(0, 8'b11111111); // expect valid=0, out=000

        $display("------ Testbench Completed ------");
        $stop;
    end

endmodule

module priority_encoder_tb;

    logic [7:0] D;
    logic EN;
    logic [2:0] Y;
    logic V;

    // Instantiate DUT
    priority_encoder dut (
        .D(D),
        .EN(EN),
        .Y(Y),
        .V(V)
    );

    // Task to display results
    task show_result();
        $display("EN=%b D=%b --> Y=%b V=%b", EN, D, Y, V);
    endtask

    initial begin
        $display("==== Priority Encoder Test ====");

        EN = 1;

        // Test all single-high inputs
        for (int i = 0; i < 8; i++) begin
            D = 8'b0;
            D[i] = 1'b1;  // set one input high
            #5; show_result();
        end

        // Test multiple inputs high (priority should pick MSB)
        D = 8'b00110110; #5; show_result(); // D5, D4, D2, D1 high → Y = D5 = 101
        D = 8'b10001111; #5; show_result(); // D7, D4, D3, D2, D1, D0 → Y = D7 = 111

        // Test all-zero input
        D = 8'b00000000; #5; show_result(); // Y=xxx, V=0

        // Test with EN=0
        EN = 0; D = 8'b11111111; #5; show_result(); // Y=xxx, V=0

        $display("==== Test Completed ====");
        $finish;
    end

endmodule


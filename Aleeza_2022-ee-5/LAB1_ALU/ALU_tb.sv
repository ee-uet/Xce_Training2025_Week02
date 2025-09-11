module ALU_tb;

    logic [7:0] A, B;
    logic [2:0] op_sel;
    logic [7:0] result;
    logic Z, C, V;

    // Instantiate DUT
    ALU dut (
        .A(A),
        .B(B),
        .op_sel(op_sel),
        .result(result),
        .Z(Z),
        .C(C),
        .V(V)
    );

    // Task to display results
    task show_result();
        $display("A=%0d B=%0d op=%b --> Result=%0d Z=%b C=%b V=%b",
                  A, B, op_sel, result, Z, C, V);
    endtask

    initial begin
        $display("==== ALU 8-bit Test ====");

        // Test ADD
        op_sel = 3'b000;
        for (int i=0; i<=5; i++) begin
            A = i;
            B = i+1;
            #5; show_result();
        end

        // Test SUB
        op_sel = 3'b001;
        for (int i=0; i<=5; i++) begin
            A = i+5;
            B = i;
            #5; show_result();
        end

        // Test AND, OR, XOR
        A = 8'b10101010; B = 8'b11001100;

        op_sel = 3'b010; #5; show_result(); // AND
        op_sel = 3'b011; #5; show_result(); // OR
        op_sel = 3'b100; #5; show_result(); // XOR

        // Test NOT
        op_sel = 3'b101; #5; show_result();

        // Test SLL/SRL
        A = 8'b00001111; B = 3'd2;
        op_sel = 3'b110; #5; show_result(); // SLL
        op_sel = 3'b111; #5; show_result(); // SRL

        $display("==== Test Completed ====");
        $finish;
    end

endmodule


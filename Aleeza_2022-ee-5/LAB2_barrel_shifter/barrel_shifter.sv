module barrel_shifter (
    input  logic [31:0] D,       // 32-bit input
    input  logic [4:0]  shift,   // Shift amount 0-31
    input  logic        dir,     // 0 = left, 1 = right
    input  logic        mode,    // 0 = shift, 1 = rotate
    output logic [31:0] Y        // 32-bit output
);

    logic [31:0] stage [4:0];  // 5 stages for 32-bit

    // Stage 0: shift/rotate by 1 if shift[0] = 1
    always_comb begin
        stage[0] = D;
        // Stage 0: shift by 1
        if (shift[0]) begin
            if (dir == 0) begin // Left
                stage[0] = mode ? {D[30:0], D[31]} : {D[30:0], 1'b0};
            end else begin     // Right
                stage[0] = mode ? {D[0], D[31:1]} : {1'b0, D[31:1]};
            end
        end
    end

    // Stage 1: shift/rotate by 2 if shift[1] = 1
    always_comb begin
        stage[1] = stage[0];
        if (shift[1]) begin
            if (dir == 0) begin // Left
                stage[1] = mode ? {stage[0][29:0], stage[0][31:30]} : {stage[0][29:0], 2'b00};
            end else begin     // Right
                stage[1] = mode ? {stage[0][1:0], stage[0][31:2]} : {2'b00, stage[0][31:2]};
            end
        end
    end

    // Stage 2: shift/rotate by 4
    always_comb begin
        stage[2] = stage[1];
        if (shift[2]) begin
            if (dir == 0) begin
                stage[2] = mode ? {stage[1][27:0], stage[1][31:28]} : {stage[1][27:0], 4'b0000};
            end else begin
                stage[2] = mode ? {stage[1][3:0], stage[1][31:4]} : {4'b0000, stage[1][31:4]};
            end
        end
    end

    // Stage 3: shift/rotate by 8
    always_comb begin
        stage[3] = stage[2];
        if (shift[3]) begin
            if (dir == 0) begin
                stage[3] = mode ? {stage[2][23:0], stage[2][31:24]} : {stage[2][23:0], 8'b0};
            end else begin
                stage[3] = mode ? {stage[2][7:0], stage[2][31:8]} : {8'b0, stage[2][31:8]};
            end
        end
    end

    // Stage 4: shift/rotate by 16
    always_comb begin
        stage[4] = stage[3];
        if (shift[4]) begin
            if (dir == 0) begin
                stage[4] = mode ? {stage[3][15:0], stage[3][31:16]} : {stage[3][15:0], 16'b0};
            end else begin
                stage[4] = mode ? {stage[3][15:0], stage[3][31:16]} : {16'b0, stage[3][31:16]};
            end
        end
    end

    assign Y = stage[4];

endmodule


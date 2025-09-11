module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,   // 0 = left, 1 = right
    input  logic        shift_rotate, // 0 = shift, 1 = rotate
    output logic [31:0] data_out
);

    // Stage signals
    logic [31:0] stage0, stage1, stage2, stage3, stage4;

    // Stage 0
    always_comb begin
        stage0 = data_in;
    end

    // ---- Stage 1: shift/rotate by 1 ----
    always_comb begin
        if (shift_amt[0]) begin
            if (left_right) begin                                   // Right
                stage1 = shift_rotate ? {stage0[0], stage0[31:1]}   // Rotate
                                      : {1'b0, stage0[31:1]};       // Shift

            end else begin                                          // Left
                stage1 = shift_rotate ? {stage0[30:0], stage0[31]}  // Rotate
                                      : {stage0[30:0], 1'b0};       // Shift
            end
        end else stage1 = stage0;
    end

    // ---- Stage 2: shift/rotate by 2 ----
    always_comb begin
        if (shift_amt[1]) begin
            if (left_right) begin                                      // Right 
                stage2 = shift_rotate ? {stage1[1:0], stage1[31:2]}    // Rotate 
                                      : {2'b0, stage1[31:2]};          // Shift 

            end else begin                                             // Left 
                stage2 = shift_rotate ? {stage1[29:0], stage1[31:30]}  // Rotate 
                                      : {stage1[29:0], 2'b0};          // Shift 
            end
        end else stage2 = stage1;
    end

    // ---- Stage 3: shift/rotate by 4 ----
    always_comb begin
        if (shift_amt[2]) begin
            if (left_right) begin                                       // Right
                stage3 = shift_rotate ? {stage2[3:0], stage2[31:4]}     // Rotate
                                      : {4'b0, stage2[31:4]};           // Shift

            end else begin                                              // Left 
                stage3 = shift_rotate ? {stage2[27:0], stage2[31:28]}   // Rotate
                                      : {stage2[27:0], 4'b0};           // Shift
            end
        end else stage3 = stage2;
    end

    // ---- Stage 4: shift/rotate by 8 ----
    always_comb begin
        if (shift_amt[3]) begin
            if (left_right) begin                                       // Right
                stage4 = shift_rotate ? {stage3[7:0], stage3[31:8]}     // Rotate
                                      : {8'b0, stage3[31:8]};           // Shift

            end else begin                                              // Left
                stage4 = shift_rotate ? {stage3[23:0], stage3[31:24]}   // Rotate
                                      : {stage3[23:0], 8'b0};           // Shift
            end
        end else stage4 = stage3;
    end

    // ---- Final stage: shift/rotate by 16 ----
    always_comb begin
        if (shift_amt[4]) begin
            if (left_right) begin
                data_out = shift_rotate ? {stage4[15:0], stage4[31:16]}
                                        : {16'b0, stage4[31:16]};
            end else begin
                data_out = shift_rotate ? {stage4[15:0], stage4[31:16]}
                                        : {stage4[15:0], 16'b0};
            end
        end else data_out = stage4;
    end

endmodule

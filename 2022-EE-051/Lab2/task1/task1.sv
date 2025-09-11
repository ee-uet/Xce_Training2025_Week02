module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,      // 0..31
    input  logic        left_right,     // 0 = left, 1 = right
    input  logic        shift_rotate,   // 0 = shift, 1 = rotate
    output logic [31:0] data_out
);

    logic [31:0] stage0, stage1, stage2, stage3, stage4;

    // Stage 0: shift/rotate by 1
    always_comb begin
        if (shift_amt[0] == 1'b1) begin
            if (shift_rotate == 1'b1) begin
                if (left_right == 1'b0) begin
                    stage0 = (data_in << 1) | (data_in >> 31);
                end else begin
                    stage0 = (data_in >> 1) | (data_in << 31);
                end
            end else begin
                if (left_right == 1'b0) begin
                    stage0 = data_in << 1;
                end else begin
                    stage0 = data_in >> 1;
                end
            end
        end else begin
            stage0 = data_in;
        end
    end

    // Stage 1: shift/rotate by 2
    always_comb begin
        if (shift_amt[1] == 1'b1) begin
            if (shift_rotate == 1'b1) begin
                if (left_right == 1'b0) begin
                    stage1 = (stage0 << 2) | (stage0 >> 30);
                end else begin
                    stage1 = (stage0 >> 2) | (stage0 << 30);
                end
            end else begin
                if (left_right == 1'b0) begin
                    stage1 = stage0 << 2;
                end else begin
                    stage1 = stage0 >> 2;
                end
            end
        end else begin
            stage1 = stage0;
        end
    end

    // Stage 2: shift/rotate by 4
    always_comb begin
        if (shift_amt[2] == 1'b1) begin
            if (shift_rotate == 1'b1) begin
                if (left_right == 1'b0) begin
                    stage2 = (stage1 << 4) | (stage1 >> 28);
                end else begin
                    stage2 = (stage1 >> 4) | (stage1 << 28);
                end
            end else begin
                if (left_right == 1'b0) begin
                    stage2 = stage1 << 4;
                end else begin
                    stage2 = stage1 >> 4;
                end
            end
        end else begin
            stage2 = stage1;
        end
    end

    // Stage 3: shift/rotate by 8
    always_comb begin
        if (shift_amt[3] == 1'b1) begin
            if (shift_rotate == 1'b1) begin
                if (left_right == 1'b0) begin
                    stage3 = (stage2 << 8) | (stage2 >> 24);
                end else begin
                    stage3 = (stage2 >> 8) | (stage2 << 24);
                end
            end else begin
                if (left_right == 1'b0) begin
                    stage3 = stage2 << 8;
                end else begin
                    stage3 = stage2 >> 8;
                end
            end
        end else begin
            stage3 = stage2;
        end
    end

    // Stage 4: shift/rotate by 16 (final output)
    always_comb begin
        if (shift_amt[4] == 1'b1) begin
            if (shift_rotate == 1'b1) begin
                if (left_right == 1'b0) begin
                    stage4 = (stage3 << 16) | (stage3 >> 16);
                end else begin
                    stage4 = (stage3 >> 16) | (stage3 << 16);
                end
            end else begin
                if (left_right == 1'b0) begin
                    stage4 = stage3 << 16;
                end else begin
                    stage4 = stage3 >> 16;
                end
            end
        end else begin
            stage4 = stage3;
        end
        data_out = stage4;
    end

endmodule

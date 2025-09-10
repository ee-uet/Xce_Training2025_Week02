module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,  // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);
    logic [31:0] stage0, stage1, stage2, stage3;

    always_comb begin
        integer i;

        // Stage 0: shift by 1
        for (i=0; i<32; i=i+1) begin
            if (shift_amt[0] == 1) begin 
                if (shift_rotate == 0) begin
                    if (left_right == 1) begin
                        if (i < 31) stage0[i] = data_in[i+1];
                        else stage0[i] = 0;
                    end else begin
                        if (i > 0) stage0[i] = data_in[i-1];
                        else stage0[i] = 0;
                    end
                end else begin
                    if (left_right == 0) stage0[i] = data_in[(i-1+32)%32];
                    else stage0[i] = data_in[(i+1)%32];
                end
            end else stage0[i] = data_in[i];
        end

        // Stage 1: shift by 2
        for (i=0; i<32; i=i+1) begin
            if (shift_amt[1] == 1) begin 
                if (shift_rotate == 0) begin
                    if (left_right == 1) begin
                        if (i < 30) stage1[i] = stage0[i+2];
                        else stage1[i] = 0;
                    end else begin
                        if (i > 1) stage1[i] = stage0[i-2];
                        else stage1[i] = 0;
                    end
                end else begin
                    if (left_right == 0) stage1[i] = stage0[(i-2+32)%32];
                    else stage1[i] = stage0[(i+2)%32];
                end
            end else stage1[i] = stage0[i];
        end

        // Stage 2: shift by 4
        for (i=0; i<32; i=i+1) begin
            if (shift_amt[2] == 1) begin 
                if (shift_rotate == 0) begin
                    if (left_right == 1) begin
                        if (i < 28) stage2[i] = stage1[i+4];
                        else stage2[i] = 0;
                    end else begin
                        if (i > 3) stage2[i] = stage1[i-4];
                        else stage2[i] = 0;
                    end
                end else begin
                    if (left_right == 0) stage2[i] = stage1[(i-4+32)%32];
                    else stage2[i] = stage1[(i+4)%32];
                end
            end else stage2[i] = stage1[i];
        end

        // Stage 3: shift by 8
        for (i=0; i<32; i=i+1) begin
            if (shift_amt[3] == 1) begin 
                if (shift_rotate == 0) begin
                    if (left_right == 1) begin
                        if (i < 24) stage3[i] = stage2[i+8];
                        else stage3[i] = 0;
                    end else begin
                        if (i > 7) stage3[i] = stage2[i-8];
                        else stage3[i] = 0;
                    end
                end else begin
                    if (left_right == 0) stage3[i] = stage2[(i-8+32)%32];
                    else stage3[i] = stage2[(i+8)%32];
                end
            end else stage3[i] = stage2[i];
        end

        // Stage 4: shift by 16
        for (i=0; i<32; i=i+1) begin
            if (shift_amt[4] == 1) begin 
                if (shift_rotate == 0) begin
                    if (left_right == 1) begin
                        if (i < 16) data_out[i] = stage3[i+16];
                        else data_out[i] = 0;
                    end else begin
                        if (i > 15) data_out[i] = stage3[i-16];
                        else data_out[i] = 0;
                    end
                end else begin
                    if (left_right == 0) data_out[i] = stage3[(i-16+32)%32];
                    else data_out[i] = stage3[(i+16)%32];
                end
            end else data_out[i] = stage3[i];
        end
    end // end always_comb
endmodule

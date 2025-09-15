module barrel_shifter (
input  logic [31:0] data_in,
input  logic [4:0]  shift_amt,
input  logic        left_right,   // 0=left, 1=right
input  logic        shift_rotate, // 0=shift, 1=rotate    
output logic [31:0] data_out
);

logic [31:0] stage0, stage1, stage2, stage3, stage4;
always_comb begin
    if (shift_amt[0]) begin
        if (!left_right) begin
            if (!shift_rotate)
                stage0 = {data_in[30:0], 1'b0};
            else
                stage0 = {data_in[30:0], data_in[31]};
        end
        else begin
            if (!shift_rotate)
                stage0 = {1'b0, data_in[31:1]};
            else
                stage0 = {data_in[0], data_in[31:1]};
        end
    end
    else begin
        stage0 = data_in;
    end
end
always_comb begin
    if (shift_amt[1]) begin
        if (!left_right) begin
            if (!shift_rotate)
                stage1 = {stage0[29:0], 2'b00};
            else
                stage1 = {stage0[29:0], stage0[31:30]};
        end
        else begin
            if (!shift_rotate)
                stage1 = {2'b00, stage0[31:2]};
            else
                stage1 = {stage0[1:0], stage0[31:2]};
        end
    end
    else begin
        stage1 = stage0;
    end
end
always_comb begin
    if (shift_amt[2]) begin
        if (!left_right) begin
            if (!shift_rotate)
                stage2 = {stage1[27:0], 4'b0000};
            else
                stage2 = {stage1[27:0], stage1[31:28]};
        end
        else begin
            if (!shift_rotate)
                stage2 = {4'b0000, stage1[31:4]};
            else
                stage2 = {stage1[3:0], stage1[31:4]};
        end
    end
    else begin
        stage2 = stage1;
    end
end
always_comb begin
    if (shift_amt[3]) begin
        if (!left_right) begin
            if (!shift_rotate)
                stage3 = {stage2[23:0], 8'h00};
            else
                stage3 = {stage2[23:0], stage2[31:24]};
        end
        else begin
            if (!shift_rotate)
                stage3 = {8'h00, stage2[31:8]};
            else
                stage3 = {stage2[7:0], stage2[31:8]};
        end
    end
    else begin
        stage3 = stage2;
    end
end
always_comb begin
    if (shift_amt[4]) begin
        if (!left_right) begin
            if (!shift_rotate)
                stage4 = {stage3[15:0], 16'h0000};
            else
                stage4 = {stage3[15:0], stage3[31:16]};
        end
        else begin
            if (!shift_rotate)
                stage4 = {16'h0000, stage3[31:16]};
            else
                stage4 = {stage3[15:0], stage3[31:16]};
        end
    end
    else begin
        stage4 = stage3;
    end
end
assign data_out = stage4;
endmodule
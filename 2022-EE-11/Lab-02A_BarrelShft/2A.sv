module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,  // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);

    // Stage signals for intermediate results
    logic [31:0] stage0, stage1, stage2, stage3, stage4;
    
    always_comb begin
        case({left_right, shift_rotate})
            2'b00: begin // Left shift
                stage0 = shift_amt[0] ? {data_in[30:0], 1'b0} : data_in;
                stage1 = shift_amt[1] ? {stage0[29:0], 2'b00} : stage0;
                stage2 = shift_amt[2] ? {stage1[27:0], 4'b0000} : stage1;
                stage3 = shift_amt[3] ? {stage2[23:0], 8'b00000000} : stage2;
                stage4 = shift_amt[4] ? {stage3[15:0], 16'b0000000000000000} : stage3;
            end
            2'b10: begin // Right shift (logical)
                stage0 = shift_amt[0] ? {1'b0, data_in[31:1]} : data_in;
                stage1 = shift_amt[1] ? {2'b00, stage0[31:2]} : stage0;
                stage2 = shift_amt[2] ? {4'b0000, stage1[31:4]} : stage1;
                stage3 = shift_amt[3] ? {8'b00000000, stage2[31:8]} : stage2;
                stage4 = shift_amt[4] ? {16'b0000000000000000, stage3[31:16]} : stage3;
            end
            2'b11: begin // Right rotate
                stage0 = shift_amt[0] ? {data_in[0], data_in[31:1]} : data_in;
                stage1 = shift_amt[1] ? {stage0[1:0], stage0[31:2]} : stage0;
                stage2 = shift_amt[2] ? {stage1[3:0], stage1[31:4]} : stage1;
                stage3 = shift_amt[3] ? {stage2[7:0], stage2[31:8]} : stage2;
                stage4 = shift_amt[4] ? {stage3[15:0], stage3[31:16]} : stage3;
            end
            2'b01: begin // Left rotate
                stage0 = shift_amt[0] ? {data_in[30:0], data_in[31]} : data_in;
                stage1 = shift_amt[1] ? {stage0[29:0], stage0[31:30]} : stage0;
                stage2 = shift_amt[2] ? {stage1[27:0], stage1[31:28]} : stage1;
                stage3 = shift_amt[3] ? {stage2[23:0], stage2[31:24]} : stage2;
                stage4 = shift_amt[4] ? {stage3[15:0], stage3[31:16]} : stage3;
            end
        endcase
    end
    
    assign data_out = stage4;
    
endmodule

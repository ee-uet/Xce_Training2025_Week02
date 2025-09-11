module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,  // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);

// TODO: Implement multi-stage shifting
// Stage signals for intermediate results
logic [31:0] stage0, stage1, stage2, stage3, stage4;
always_comb begin
    // TODO: Implement each stage
    // Consider: How to handle fill bits for shifts vs rotates?
    case ({left_right,shift_rotate})
    // left shift
    2'b00:  begin
     if (shift_amt[0] == 0) 
        stage0 = data_in;
     else 
        stage0 = data_in << 1;
    if (shift_amt[1] == 0) 
        stage1 = stage0;
    else 
        stage1 = stage0 << 2;
    if (shift_amt[2] == 0) 
        stage2 = stage1;
    else 
        stage2 = stage1 << 4;
    if (shift_amt[3] == 0) 
        stage3 = stage2;
    else 
        stage3 = stage2 << 8;
    if (shift_amt[4] == 0) 
        stage4 = stage3;
    else 
        stage4 = stage3 << 16;
    data_out = stage4;
    end
    // right shift
    2'b10: begin
    if (shift_amt[0] == 0) 
        stage0 = data_in;
    else 
        stage0 = data_in >> 1;
    if (shift_amt[1] == 0) 
        stage1 = stage0;
    else 
        stage1 = stage0 >> 2;
    if (shift_amt[2] == 0) 
        stage2 = stage1;
    else 
        stage2 = stage1 >> 4;
    if (shift_amt[3] == 0) 
        stage3 = stage2;
    else 
        stage3 = stage2 >> 8;
    if (shift_amt[4] == 0) 
        stage4 = stage3;
    else 
        stage4 = stage3 >> 16;
    data_out = stage4;
    end
    //left rotate
    2'b01: begin
    if (shift_amt[0] == 0) 
        stage0 = data_in;
    else 
        stage0 = (data_in << 1) | (data_in >> 31);
    if (shift_amt[1] == 0) 
        stage1 = stage0;
    else 
        stage1 = (stage0 << 2) | (stage0 >> 30) ;
    if (shift_amt[2] == 0) 
        stage2 = stage1;
    else 
        stage2 = (stage1 << 4) | (stage1 >> 28);
    if (shift_amt[3] == 0) 
        stage3 = stage2;
    else 
        stage3 = (stage2 << 8) | (stage2 >> 24);
    if (shift_amt[4] == 0) 
        stage4 = stage3;
    else 
        stage4 = (stage3 << 16) | (stage3 >> 16);
    data_out = stage4;
    end
    // right rotate 
    2'b11: begin
    if (shift_amt[0] == 0) 
        stage0 = data_in;
    else 
        stage0 = (data_in >> 1) | (data_in << 31);
    if (shift_amt[1] == 0) 
        stage1 = stage0;
    else 
        stage1 = (stage0 >> 2) | (stage0 << 30) ;
    if (shift_amt[2] == 0) 
        stage2 = stage1;
    else 
        stage2 = (stage1 >> 4) | (stage1 << 28);
    if (shift_amt[3] == 0) 
        stage3 = stage2;
    else 
        stage3 = (stage2 >> 8) | (stage2 << 24);
    if (shift_amt[4] == 0) 
        stage4 = stage3;
    else 
        stage4 = (stage3 >> 16) | (stage3 << 16);
    data_out = stage4;
    end
    endcase
end
endmodule

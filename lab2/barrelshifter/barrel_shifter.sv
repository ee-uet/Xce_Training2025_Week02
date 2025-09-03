module barrel_shifter (
    input  logic [31:0] a,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,   // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] y
);


    logic [31:0] s0, s1, s2, s3;

    always_comb begin
        if (left_right) begin
            
            if (shift_rotate) begin
                // Right Rotate
                s0 = shift_amt[0] ? {a[0],a[31:1]}     : a;
                s1 = shift_amt[1] ? {s0[1:0],s0[31:2]} : s0;
                s2 = shift_amt[2] ? {s1[3:0],s1[31:4]} : s1;
                s3 = shift_amt[3] ? {s2[7:0],s2[31:8]} : s2;
                y  = shift_amt[4] ? {s3[15:0],s3[31:16]} : s3;
            end else begin
                // Right Shift (zero fill)
                s0 = shift_amt[0] ? {1'b0,a[31:1]}  : a;
                s1 = shift_amt[1] ? {2'b0,s0[31:2]} : s0;
                s2 = shift_amt[2] ? {4'b0,s1[31:4]} : s1;
                s3 = shift_amt[3] ? {8'b0,s2[31:8]} : s2;
                y  = shift_amt[4] ? {16'b0,s3[31:16]} : s3;
            end
        end else begin
            
            if (shift_rotate) begin
                // Left Rotate
                s0 = shift_amt[0] ? {a[30:0],a[31]}      : a;
                s1 = shift_amt[1] ? {s0[29:0],s0[31:30]} : s0;
                s2 = shift_amt[2] ? {s1[27:0],s1[31:28]} : s1;
                s3 = shift_amt[3] ? {s2[23:0],s2[31:24]} : s2;
                y  = shift_amt[4] ? {s3[15:0],s3[31:16]} : s3;
            end else begin
                // Left Shift (zero fill)
                s0 = shift_amt[0] ? {a[30:0],1'b0}  : a;
                s1 = shift_amt[1] ? {s0[29:0],2'b0} : s0;
                s2 = shift_amt[2] ? {s1[27:0],4'b0} : s1;
                s3 = shift_amt[3] ? {s2[23:0],8'b0} : s2;
                y  = shift_amt[4] ? {s3[15:0],16'b0} : s3;
            end
        end
    end

endmodule

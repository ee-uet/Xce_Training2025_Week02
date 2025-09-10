module barrel_shifter (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        left_right,   // 0=left, 1=right
    input  logic        shift_rotate, // 0=shift, 1=rotate
    output logic [31:0] data_out
);

    // For right shifts/rotates, handling it directly
    // For left operations, we'll reverse the bits, first right operation, then  reversing back
    
    logic [31:0] effective_input;
    logic [31:0] shifted_result;
    logic [31:0] reversed_input;
    logic [31:0] reversed_output;
    
    // Reverse bits for left operations
    generate
        for (genvar i = 0; i < 32; i++) begin
            assign reversed_input[i] = data_in[31-i];
            assign reversed_output[i] = shifted_result[31-i];
        end
    endgenerate
    
    // Choose input based on direction
    assign effective_input = left_right ? data_in : reversed_input;//not reversing for Right shift so,effective_input = data_in 
    
   // if (shift_amt[stage]) {
   // shifted_result = shift_rotate ?
      //  {bits rotated} :
      //  {bits shifted with zeros};

    // Right shift/rotate implementation
    always_comb begin
        // Stage 0: Shift by 0 or 1 bit
        if (shift_amt[0]) begin
            shifted_result = shift_rotate ? 
                {effective_input[0], effective_input[31:1]} : // rotate
                {1'b0, effective_input[31:1]};               // shift
        end else begin
            shifted_result = effective_input;
        end 
        
        // Stage 1: Shift by 0 or 2 bits
        if (shift_amt[1]) begin
            shifted_result = shift_rotate ? 
                {shifted_result[1:0], shifted_result[31:2]} : // rotate
                {2'b00, shifted_result[31:2]};               // shift
        end
        
        // Stage 2: Shift by 0 or 4 bits
        if (shift_amt[2]) begin
            shifted_result = shift_rotate ? 
                {shifted_result[3:0], shifted_result[31:4]} : // rotate
                {4'b0000, shifted_result[31:4]};             // shift
        end
        
        // Stage 3: Shift by 0 or 8 bits
        if (shift_amt[3]) begin
            shifted_result = shift_rotate ? 
                {shifted_result[7:0], shifted_result[31:8]} : // rotate
                {8'b00000000, shifted_result[31:8]};         // shift
        end
        
        // Stage 4: Shift by 0 or 16 bits
        if (shift_amt[4]) begin
            shifted_result = shift_rotate ? 
                {shifted_result[15:0], shifted_result[31:16]} : // rotate
                {16'b0000000000000000, shifted_result[31:16]}; // shift
        end
    end
    
    // choosing output based on direction
    assign data_out = left_right ? shifted_result : reversed_output;

endmodule

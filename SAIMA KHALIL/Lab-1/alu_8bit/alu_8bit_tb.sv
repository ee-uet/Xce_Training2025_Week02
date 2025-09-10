 module alu_8bit_tb;
    logic signed [7:0] a, b;
    logic signed[2:0] op_sel;
    logic [7:0] result;
    logic       zero;
    logic carry;
    logic overflow;

    alu_8bit dut (.*);

    initial begin
        //  Addition  
        a = 10; b = 5; op_sel = 3'b000; #5;
        
        //  Subtraction 
        a = 10; b = 5; op_sel = 3'b001; #5;
        
        //  Multiplication 
        a = 7; b = 3; op_sel = 3'b010; #5;

        //  Division 
        a = 20; b = 4; op_sel = 3'b011; #5;
        
        // AND 
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b100; #5;
       
        // OR 
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b101; #5;
        
        // XOR 
        a = 8'b10101010; b = 8'b11001100; op_sel = 3'b110; #5;
     
        // NOT 
        a = 8'b10101010; b = 8'b00000000; op_sel = 3'b111; #5;
    
        $finish;
    end
endmodule

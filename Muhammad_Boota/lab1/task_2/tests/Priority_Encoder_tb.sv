module   Priority_Encoder_tb#(TEST=1000)();
    logic [7:0]operand;
    logic enable;
    logic [2:0]out;
    logic valid;

    Priority_Encoder priority_encoder( .* );

    initial begin
        for (int i =0 ;i<TEST ;i++ ) begin
            operand  = $urandom_range(-128,128);
            enable   = $urandom_range(0,1);
            #1;
            $display("num=%b,enable=%b,output=%b,valid=%b",operand,enable,out,valid);
        end
    end


endmodule
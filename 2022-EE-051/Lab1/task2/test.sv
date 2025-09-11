module tb_priority_encoder_8to3;
    logic       enable;
    logic [7:0] data_in;
    logic [2:0] encoded_out;
    logic       valid;

  
    priority_encoder_8to3 dut (.*);

    task show_result;
        input [7:0] data_in;
        begin
            $display("enable=%b data_in=%b encoded_out=%b valid=%b",
                     enable, data_in, encoded_out, valid);
        end
    endtask

    initial begin
        // Case 0: all zeros
        enable   = 1;
        data_in  = 8'b0000_0000; #5; show_result(data_in);

        // One-hot inputs
        data_in  = 8'b0000_0001; #5; show_result(data_in); 
        data_in  = 8'b0000_0010; #5; show_result(data_in); 
        data_in  = 8'b0000_0100; #5; show_result(data_in); 
        data_in  = 8'b0000_1000; #5; show_result(data_in);
        data_in  = 8'b0001_0000; #5; show_result(data_in); 
        data_in  = 8'b0010_0000; #5; show_result(data_in); 
        data_in  = 8'b0100_0000; #5; show_result(data_in); 
        data_in  = 8'b1000_0000; #5; show_result(data_in); 

        data_in  = 8'b0000_1010; #5; show_result(data_in);
        data_in  = 8'b0110_0000; #5; show_result(data_in); 
        data_in  = 8'b1001_0000; #5; show_result(data_in); 
        data_in  = 8'b1111_1111; #5; show_result(data_in); 

        enable   = 0;
        data_in  = 8'b1000_0000; #5; show_result(data_in);

        $finish;
    end

endmodule

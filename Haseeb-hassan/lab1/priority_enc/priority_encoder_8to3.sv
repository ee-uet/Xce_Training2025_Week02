module priority_encoder_8to3 (
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [2:0] encoded_out,
    output logic       valid
);

    // TO: Implement priority encoding
    always_comb begin 

        if (!enable) begin
            valid = 0;
            encoded_out = 3'b0;
            
        end
        else    begin
            valid = data_in[7]|data_in[6]|data_in[5]|data_in[4]|data_in[3]|data_in[2]|data_in[1]|data_in[0] ;  
            casez (data_in)
                8'b1???????: encoded_out = 3'b111; 
                8'b01??????: encoded_out = 3'b110; 
                8'b001?????: encoded_out = 3'b101; 
                8'b0001????: encoded_out = 3'b100; 
                8'b00001???: encoded_out = 3'b011; 
                8'b000001??: encoded_out = 3'b010; 
                8'b0000001?: encoded_out = 3'b001; 
                8'b00000001: encoded_out = 3'b000; 
                default    : encoded_out = 3'b000; 
            endcase
            
        end

    end
    
    
endmodule


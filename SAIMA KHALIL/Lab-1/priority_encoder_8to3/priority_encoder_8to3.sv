module priority_encoder_8to3 ( 
input  logic  enable, 
input  logic [7:0] data_in, 
output logic [2:0] encoded_out, 
output logic      valid 
); 
    always_comb begin
        if (!enable) begin
            encoded_out = 3'b000;
            valid = 1'b0;
        end else begin
            casex (data_in)
                8'b1xxxxxxx: begin encoded_out = 3'b111; valid = 1'b1; end
                8'b01xxxxxx: begin encoded_out = 3'b110; valid = 1'b1; end
                8'b001xxxxx: begin encoded_out = 3'b101; valid = 1'b1; end
                8'b0001xxxx: begin encoded_out = 3'b100; valid = 1'b1; end
                8'b00001xxx: begin encoded_out = 3'b011; valid = 1'b1; end
                8'b000001xx: begin encoded_out = 3'b010; valid = 1'b1; end
                8'b0000001x: begin encoded_out = 3'b001; valid = 1'b1; end
                8'b00000001: begin encoded_out = 3'b000; valid = 1'b1; end
                default: begin encoded_out = 3'b000; valid = 1'b0; end // No bits set
            endcase
        end
    end
endmodule 

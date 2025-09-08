module priority_encoder_8to3 (
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [2:0] encoded_out,
    output logic       valid
);

    always_comb begin
        if (!enable) begin
            // When disabled, output is zero and not valid
            encoded_out = 3'b000;
            valid = 1'b0;
        end
        else begin
            // Priority encoding when enabled
            casez (data_in)
                8'b1???????: begin encoded_out = 3'b111; valid = 1'b1; end
                8'b01??????: begin encoded_out = 3'b110; valid = 1'b1; end
                8'b001?????: begin encoded_out = 3'b101; valid = 1'b1; end
                8'b0001????: begin encoded_out = 3'b100; valid = 1'b1; end
                8'b00001???: begin encoded_out = 3'b011; valid = 1'b1; end
                8'b000001??: begin encoded_out = 3'b010; valid = 1'b1; end
                8'b0000001?: begin encoded_out = 3'b001; valid = 1'b1; end
                8'b00000001: begin encoded_out = 3'b000; valid = 1'b1; end
                default:     begin encoded_out = 3'b000; valid = 1'b0; end
            endcase
        end
    end
    
endmodule

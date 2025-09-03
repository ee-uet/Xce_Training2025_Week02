module priority_encoder_8to3 (
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [2:0] encoded_out,
    output logic       valid
);

    // TOO Implement priority encoding
    always_comb begin
        if  (!enable) begin
            valid       = 1'b0;
            encoded_out = 3'b000;
        end
        else begin
            casez(data_in)
                8'b00000000: begin
                    valid       = 1'b0;
                    encoded_out = 3'b000;
                end
                8'b00000001: begin
                    valid       = 1'b1;
                    encoded_out = 3'b000;
                end
                8'b0000001?: begin
                    valid       = 1'b1;
                    encoded_out = 3'b001;
                end
                8'b000001??: begin
                    valid       = 1'b1;
                    encoded_out = 3'b010;
                end
                8'b00001???: begin
                    valid       = 1'b1;
                    encoded_out = 3'b011;
                end
                8'b0001????: begin
                    valid       = 1'b1;
                    encoded_out = 3'b100;
                end
                8'b001?????: begin
                    valid       = 1'b1;
                    encoded_out = 3'b101;
                end
                8'b01??????: begin
                    valid       = 1'b1;
                    encoded_out = 3'b110;
                end
                8'b1???????: begin
                    valid       = 1'b1;
                    encoded_out = 3'b111;
                end
                default:     begin
                    valid       = 1'b0;
                    encoded_out = 3'b000;
                end
            endcase
        end
    end


endmodule

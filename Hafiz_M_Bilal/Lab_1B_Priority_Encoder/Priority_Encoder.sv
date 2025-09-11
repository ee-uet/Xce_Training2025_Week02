module Priority_Encoder(
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [2:0] encoded_out,
    output logic       valid
);

    always_comb begin
        if (!enable) begin
            encoded_out = 3'b000;
            valid       = 1'b0;
        end
        else begin
            valid       = |data_in;   // valid = 1 if any bit is high
            casez (data_in)
                8'b1???????: encoded_out = 3'b111; // data_in[7]
                8'b01??????: encoded_out = 3'b110; // data_in[6]
                8'b001?????: encoded_out = 3'b101; // data_in[5]
                8'b0001????: encoded_out = 3'b100; // data_in[4]
                8'b00001???: encoded_out = 3'b011; // data_in[3]
                8'b000001??: encoded_out = 3'b010; // data_in[2]
                8'b0000001?: encoded_out = 3'b001; // data_in[1]
                8'b00000001: encoded_out = 3'b000; // data_in[0]
                default:     encoded_out = 3'b000; // no input active
            endcase
        end
    end

endmodule

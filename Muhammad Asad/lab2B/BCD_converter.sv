/*
    BCD Converter
    Converts an 8-bit binary number to a 12-bit BCD representation.
*/

module BCD_converter (
    input  logic [7:0]  binary_in,
    output logic [11:0] bcd
);

logic [19:0] bcd_temp; // temporary register to binary_in and bcd for shifting

always_comb begin
    bcd_temp[7:0] =   binary_in;;
    bcd_temp[11:8] =  bcd[3:0];
    bcd_temp[15:12] = bcd[7:4];
    bcd_temp[19:16] = bcd[11:8];
    for(int i=0 ;i<8 ;i++){
        if(bcd_temp[11:8] >= 4'd5) begin
            bcd_temp[11:8] = bcd_temp[11:8] + 4'd3;
        end
        else begin
            bcd_temp[11:8] = bcd_temp[11:8];
        end
        if(bcd_temp[15:12] >= 4'd5) begin
            bcd_temp[15:12] = bcd_temp[15:12] + 4'd3;
        end
        else begin
            bcd_temp[15:12] = bcd_temp[15:12];
        end
        if(bcd_temp[19:16] >= 4'd5) begin
            bcd_temp[19:16] = bcd_temp[19:16] + 4'd3;
        end
        else begin
            bcd_temp[19:16] = bcd_temp[19:16];
        end
        bcd_temp = {bcd_temp[19:16], bcd_temp[15:12], bcd_temp[11:8], bcd_temp[7:0]};
        bcd_temp = bcd_temp << 1;
        
    }

    
end
assign bcd = bcd_temp[19:8]; // assign the output bcd to the relevant bits of bcd_temp

endmodule
module bin_to_bcd (
    input logic [7:0]bin,
    output logic [11:0]bcd
);
logic [7:0]temp_bin;
always_comb begin
        bcd=12'b0;    
        temp_bin = bin;
     for(int i=0;i<8;i++) begin //loop will run for no of binary bits time
        if(bcd[3:0]>=5) begin
            bcd[3:0]=bcd[3:0]+3;
        end
        if(bcd[7:4]>=5) begin
            bcd[7:4]=bcd[7:4]+3;
        end
        if(bcd[11:8]>=5) begin
            bcd[11:8]=bcd[11:8]+3;
        end


    bcd={bcd[10:0],temp_bin[7]};
    temp_bin={temp_bin[6:0],1'b0};
   
 end
end
endmodule
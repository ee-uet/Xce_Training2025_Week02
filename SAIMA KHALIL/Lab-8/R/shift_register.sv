module shiftregister(
    input  logic        baud16,
    input  logic        reset,
    input  logic        serial_input,
    output logic        s_empty,
    output logic        last_bit,
    output logic        done_shifting,
    output logic [7:0] s_data_out
);  
    logic [9:0] shiftRegister;
    logic        receiving;
    logic        sampledValue;
    logic [3:0]  bit_count;
    logic [3:0]  sample_count;
    logic first_sample;
    always_ff @(posedge baud16 or posedge reset) begin
        if (reset) begin
            sample_count     <= 0;
            bit_count        <= 0;
            shiftRegister   <= 0;
            s_data_out <= 0;
            s_empty   <= 1;
            done_shifting            <= 0;
            receiving       <= 0;
            first_sample    <= 1;
        end  

            // Detect start bit: serial_input == 0 
        if (first_sample && !receiving &&  !serial_input) begin
            receiving   <= 1;
            sample_count <= 0;   
            bit_count    <= 0;
            s_empty <= 0;
        end
        if (receiving) begin
        sample_count <= sample_count + 1;
        if (first_sample && bit_count == 0 && sample_count == 7) begin
        // First mid-bit sample
        sampledValue <= serial_input;
        shiftRegister <= {serial_input, shiftRegister[8:1]};
        bit_count <= 1;
        sample_count <= 0;
        first_sample<=0;
        done_shifting<=0;
        end 
        else if (bit_count > 0 && sample_count == 15) begin
            sampledValue <= serial_input;
            shiftRegister <= {serial_input, shiftRegister[8:1]};
            bit_count <= bit_count + 1;
            first_sample<=0;
            sample_count <= 0;
                    
            if (bit_count == 10 && serial_input==1) begin
            s_data_out <= shiftRegister;
            done_shifting <= 1;
            s_empty <= 1;
            receiving <= 0;
            bit_count <= 0;
            last_bit <= shiftRegister[0];
            first_sample<=1;
                    end
                end
            end
        end
    
endmodule

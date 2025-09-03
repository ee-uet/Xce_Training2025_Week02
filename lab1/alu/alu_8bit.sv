module alu_8bit (
    input  logic [7:0] a, b,
    input  logic [2:0] op_sel,
    output logic [7:0] result,
    output logic       zero, carry, overflow
);

    // TO: Implement operation selection
    logic [8:0] flag_cheker;
    always_comb begin
        
        carry       = 1'b0;
        overflow    = 1'b0;
        zero        = 1'b0;
        result      = 8'b0;
        
        case (op_sel)
            3'b000 : begin

                flag_cheker     = a + b;
                result          = flag_cheker[7:0];
                carry           = flag_cheker[8];
                overflow        = (a[7] == b[7]) && (result[7] != a[7]);

            end
            3'b001 : begin 
                 flag_cheker    = a - b ;
                 result         = flag_cheker[7:0];
                 carry          = flag_cheker[8];
                 overflow       = (a[7] != b[7]) && (result[7] != a[7]);
            end
            3'b010 : result = a & b;
            3'b011 : result = a | b;
            3'b100 : result = a ^ b;
            3'b101 : result = ~ a;
            3'b110 : begin
                result           = {a[6:0],1'b0};
                carry            = a[7];
            end
            3'b111 :  begin 
               result            = {1'b0,a[7:1]};
               carry             = a[0];
            end

            // TO: Implement each operation
            // Consider overflow detection logic
            default: result       = 8'b0;
        endcase

        if (result == 8'b0)
            zero = 1'b1;
        else 
            zero = 1'b0;
        
        // TO: Implement flag generation
    end

endmodule


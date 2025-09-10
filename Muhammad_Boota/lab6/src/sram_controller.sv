import pkg::*;
module sram_controller (
    input  logic        clk,         
    input  logic        rst_n,       
    input  logic        read_req,    
    input  logic        write_req,   
    input  logic [14:0] address,     
    input  logic [15:0] write_data,  
    output logic [15:0] read_data,  
    output logic        ready,       
    // SRAM interface
    output logic [14:0] sram_addr,  
    inout  wire [15:0]  sram_data,  
    output logic        sram_ce_n,  
    output logic        sram_oe_n,  
    output logic        sram_we_n    
);

    sram_state state, next_state;

logic [15:0]sram[(1<<16)-1:0];
always_ff @( posedge clk ) begin : blockName
    if (state==WRITE)begin
        sram[sram_addr]<=write_data;
    end
end



    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= INITIAL;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        sram_ce_n = 1'b1;
        sram_oe_n = 1'b1;
        sram_we_n = 1'b1;
        sram_addr = 0;
        ready = 1'b1;
        sram_addr = address;
        read_data  = sram_data;

        case (state)
            INITIAL: begin
                if (write_req )
                    next_state = WRITE;
                else if (read_req)
                    next_state = READ;
                else
                    next_state = INITIAL;
            end
            READ: begin
                sram_ce_n = 1'b0;
                sram_oe_n = 1'b0;
                sram_we_n = 1'b1;
                if (write_req )
                    next_state = WRITE;
                else if (read_req)
                    next_state = READ;
                else
                    next_state = INITIAL;
            end
            WRITE: begin
                sram_ce_n = 1'b0;
                sram_oe_n = 1'b1;
                sram_we_n = 1'b0;
                ready = 1'b0;
                next_state = DONE;
            end
            DONE: begin
                ready = 1'b1;
                if (write_req )
                    next_state = WRITE;
                else if (read_req)
                    next_state = READ;
                else
                    next_state = INITIAL;
            end
        endcase
    end
assign sram_data=sram[sram_addr];
endmodule
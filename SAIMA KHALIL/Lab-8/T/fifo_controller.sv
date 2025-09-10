module fifo_controller(
    input logic clk,
    input logic rst,
    input logic tx_valid,
    input logic f_full,
    input logic f_empty,
    output logic wr_en,
    output logic tx_ready,
    output logic rd_en       // FIFO read enable
    
);
typedef enum logic [1:0] {IDLE, LOAD} state_t;
    state_t cs, ns;
    always_comb begin
        case(cs) 
            IDLE:if(!tx_valid || f_full)ns=IDLE;
            else ns=LOAD;
            LOAD:if(!tx_valid || f_full)ns=IDLE;
            else if(tx_valid && !f_full) ns=LOAD;
        endcase 
    end
   always_comb begin
    // defaults
    wr_en    = 0;
    rd_en    = 0;
    tx_ready = 0;

    case(cs)
        IDLE: begin
            if (tx_valid && !f_full) begin
                wr_en    = 1;
                tx_ready = 1;
            end
        end
        LOAD: begin
            if (!f_empty) begin
                rd_en = 1;
            end
        end
    endcase
end

     always_ff @(posedge clk or posedge rst) begin
        if(rst)
            cs <= IDLE;
        else
            cs <= ns;
    end
endmodule 
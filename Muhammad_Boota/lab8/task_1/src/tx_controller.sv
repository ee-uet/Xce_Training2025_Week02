import pkg::*;
module tx_controller (
    input logic clk,rst_n,
    input logic tx_en,baud_en,bit_count,tx_busy,
    output logic baud_reg_en,shift_en,shift_reg_en,bit_count_reg_en,fifo_rd_en
);
    uart_transmit curr_state,next_state;
    always_comb begin 
        case (curr_state)
            IDEAL: next_state=(tx_en & tx_busy) ? LOAD:IDEAL;
            LOAD: next_state=START_BIT;
            START_BIT: next_state=(baud_en) ? DATA_BITS:START_BIT;
            DATA_BITS: next_state=(bit_count) ? PARITY:DATA_BITS;
            PARITY: next_state=(baud_en) ? STOP_BIT:PARITY;
            STOP_BIT: next_state=(baud_en) ? IDEAL:STOP_BIT;
            default: next_state=IDEAL;
        endcase
    end

    always_ff @( posedge clk ) begin 
        if (!rst_n) begin
            curr_state<=IDEAL;
        end else begin
            curr_state<=next_state;
        end
    end

    always_comb begin 
        baud_reg_en=1'b0;
        shift_en=1'b0;
        shift_reg_en=1'b0;
        bit_count_reg_en=1'b0;
        fifo_rd_en=1'b0;
        case (curr_state)
            LOAD:begin
                fifo_rd_en=1'b1;
                shift_reg_en=1'b1;
            end
            START_BIT:begin
                baud_reg_en=1'b1;
                shift_en=baud_en;
            end
            DATA_BITS:begin
                baud_reg_en=1'b1;
                shift_en=baud_en;
                bit_count_reg_en=baud_en;
            end
            PARITY:begin
                baud_reg_en=1'b1;
                shift_en=baud_en;
                bit_count_reg_en=baud_en;
            end
            STOP_BIT:begin
                baud_reg_en=1'b1;
            end
            default: begin
                
            end
        endcase
    end
endmodule
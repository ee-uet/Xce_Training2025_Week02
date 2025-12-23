import pkg::*;
module rx_controller (
    input logic clk,rst_n,data_in,baud_rate,bit_count,uart_rx_en,
    output logic sampling_en,baud_rate_en,parity,stop_bit_error,fifo_Rx_Valid,
    output uart_status_reg_en uart_status_en
);
    uart_receive curr_state,next_state;
    always_ff @( posedge clk ) begin : blockName
        if (!rst_n) begin
            curr_state<=RX_IDEAL;
        end else begin
            curr_state<=next_state;
        end
    end
    
    always_comb begin 
        case (curr_state)
            RX_IDEAL: next_state=((!data_in) && (uart_rx_en))? RX_START_BIT:RX_IDEAL;
            RX_START_BIT:next_state=(baud_rate) ? RX_DATA_BITS:RX_START_BIT;
            RX_DATA_BITS:next_state=(baud_rate & bit_count) ? RX_PARITY:RX_DATA_BITS;
            RX_PARITY:next_state=(baud_rate) ? RX_STOP_BIT:RX_PARITY;
            RX_STOP_BIT:next_state=(baud_rate) ? RX_IDEAL:RX_STOP_BIT;
            default: next_state=RX_IDEAL;
        endcase
    end

    always_comb begin 
        baud_rate_en=!data_in;
        sampling_en=1'b0;
        uart_status_en.parity_bit=1'b0;
        parity=1'b0;
        uart_status_en.stop_bit=1'b0;
        stop_bit_error=1'b0;
        fifo_Rx_Valid=1'b0;
        case (curr_state)
            RX_START_BIT:begin
                baud_rate_en=1'b1;
            end
            RX_DATA_BITS:begin
                sampling_en=1'b1;
                baud_rate_en=1'b1;
                fifo_Rx_Valid=(baud_rate & bit_count);
            end
            RX_PARITY:begin
                baud_rate_en=1'b1;
                uart_status_en.parity_bit=1;
                parity=data_in;
                
            end
            RX_STOP_BIT:begin
                baud_rate_en=1'b1;
                uart_status_en.stop_bit=1;
                stop_bit_error =!data_in;
            end
            default: begin
                
            end
        endcase
    end
    
endmodule
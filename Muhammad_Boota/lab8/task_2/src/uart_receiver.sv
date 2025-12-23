import pkg::*;
module uart_receiver #(
parameter int CLK_FREQ = 50_000_000,
parameter int BAUD_RATE = 115200,
parameter int FIFO_DEPTH = 8,
parameter int PARITY=1 //even parity
) (
    input logic clk,rst_n,uart_rx_en,data_in,Tx_Ready,
    output logic [7:0] Tx_Data,
    output logic Tx_Valid,parity_error_o,stop_bit_error_o
);
    logic baud_rate,bit_count,fifo_Rx_Valid,sample,sampling_en;
    logic baud_rate_en,parity;
    uart_status_reg_en uart_status_en;
    logic [7:0] fifo_Rx_Data;
    logic parity_error,stop_bit_error;


        generate
            always_comb begin
               if (PARITY) begin
                    parity_error=(parity==(~(^fifo_Rx_Data)));
                end else begin
                    parity_error=(parity==(^fifo_Rx_Data));
                end 
            end
            

        endgenerate

    uart_status_reg Uart_Status_Reg(
        .*
    );

    fifo #(FIFO_DEPTH) Fifo (
        .Rx_Data(fifo_Rx_Data),.Rx_Valid(fifo_Rx_Valid),.*
    );

    rx_shift_reg Rx_Shift_Reg(
        .rx_shift_reg_en(sample),
        .*
    );

    rx_controller Rx_Controller(
        .*
    );

    counter #(CLK_FREQ/BAUD_RATE) Baud_Rate_Reg (
        .counted(baud_rate),.enable(baud_rate_en),
        .*
    );
    sampling_counter #(CLK_FREQ/BAUD_RATE) Sampling_Counter_Reg (
        .counted(sample),.enable(sampling_en),
        .*
    );
    counter #(8) Bit_Counter_Reg (
        .counted(bit_count),.enable(sample),
        .*
    );
endmodule
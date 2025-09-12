import pkg::*;
module uart_receiver_tb #(
    TESTS=100,
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 8,
    parameter int PARITY=1 //even parity
)();
logic [7:0] wdata_q[$];
logic clk,rst_n,uart_rx_en,data_in,Tx_Ready;
logic [7:0] Tx_Data;
logic Tx_Valid,parity_error_o,stop_bit_error_o;

logic baud_clk;
counter #(CLK_FREQ/BAUD_RATE) Baud_clk_generater (
    .counted(baud_clk),.enable(1'b1),
    .*
);

uart_receiver Uart_Receiver(
    .*
);
initial begin
    clk=0;
    forever begin
        #10 clk=~clk;
    end
end
initial begin
    rst_n=0;
    Tx_Ready=0;
    #20;
    data_in=1;
    rst_n=1;
    @(posedge clk);
    for (int i =0 ;i<TESTS ;i++ ) begin
        fork
          send_data();
          receiver_data(i);  
        join
    end
    $stop;
end


task automatic send_data();
    logic [7:0] data=$urandom_range(0,255);
    data_in=1;
    uart_rx_en=1;
    @(posedge baud_clk);
    wdata_q.push_back(data);
    data_in=0; // start bit
    @(posedge baud_clk);
    for (int i =0 ;i<8 ;i++ ) begin //data bits
        data_in=data[i];
        @(posedge baud_clk);
    end
    data_in=(PARITY) ? !(^data):^data; // parity bit
    @(posedge baud_clk);
    data_in=1; //stop bit
    uart_rx_en=0;
endtask //automatic

task automatic receiver_data(input int i);
    logic [7:0] data_out;
    Tx_Ready=1;
    @(posedge clk);
    while (!Tx_Valid) @(posedge clk);
    data_out=wdata_q.pop_front();
    if (Tx_Data != data_out) begin
        $display("Test:%d failed;\n expected data: %h \n received data: %h",i,data_out,Tx_Data);
        $stop;
    end else begin
        $display("Test:%d passed ,stop bit error:%d,parity_error:%d",i,stop_bit_error_o,parity_error_o);
    end
    @(posedge clk);
    Tx_Ready=0;
    @(posedge clk);
endtask //automatic
endmodule
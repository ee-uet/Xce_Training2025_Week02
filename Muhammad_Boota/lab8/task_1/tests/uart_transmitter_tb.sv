module uart_transmitter_tb #( TEST=15,
parameter int CLK_FREQ = 50_000_000,
parameter int BAUD_RATE = 115200,
parameter int FIFO_DEPTH = 8
)();
logic clk;
logic rst_n;
logic [7:0] tx_data;
logic tx_en;
logic tx_valid;
logic tx_ready;
logic tx_serial;
logic tx_busy;

uart_transmitter Uart_Transmitter(
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
    #20;
    rst_n=1;
    @(posedge(clk));
    tx_en=1;
    for (int i =0 ;i<TEST ;i++ ) begin
        tx_valid=1;
        tx_data=$urandom_range(0,255);
        while(!tx_ready)begin
            
            @(posedge (clk));
        end
        @(posedge(clk));
        tx_valid=0;
        @(posedge(clk));
    end
end

endmodule
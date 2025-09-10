import pkg::*;
module spi_master_tb #( TESTS=100,
parameter int NUM_SLAVES = 4,
parameter int DATA_WIDTH = 8
)();
logic clk;
logic rst_n;
logic [DATA_WIDTH-1:0] tx_data;
logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
logic start_transfer;
logic cpol;
logic cpha;
logic [15:0] clk_div;
logic [DATA_WIDTH-1:0] rx_data;
logic transfer_done;
logic busy;
logic spi_clk;
logic spi_mosi;
logic spi_miso;
logic [NUM_SLAVES-1:0] spi_cs_n;

spi_master spi_master(
    .*
);
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end

initial begin
    rst_n=0;
    #20
    rst_n=1;
    @(posedge(clk));
    for (int i =0 ;i<TESTS ;i++ ) begin
        tx_data=$urandom_range(0,256);
        slave_sel=$urandom_range(0,3);
        cpha=$urandom_range(0,1);
        cpol=$urandom_range(0,1);
        clk_div=$urandom_range(0,8);
        @(posedge (clk));
        start_transfer=1;
        while(!transfer_done)begin
            spi_miso=$urandom_range(0,1);
            @(posedge clk);
        end
        start_transfer=0;
        @(posedge clk);
    end
    $finish;
end

endmodule
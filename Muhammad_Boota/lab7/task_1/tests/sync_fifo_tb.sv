module sync_fifo_tb #(TESTS=100,
parameter int DATA_WIDTH = 8,
parameter int FIFO_DEPTH = 16,
parameter int ALMOST_FULL_THRESH = 14,
parameter int ALMOST_EMPTY_THRESH = 2
)();
logic clk;
logic rst_n;
logic wr_en;
logic [DATA_WIDTH-1:0] wr_data;
logic rd_en;
logic [DATA_WIDTH-1:0] rd_data;
logic full;
logic empty;
logic almost_full;
logic almost_empty;
logic [$clog2(FIFO_DEPTH):0] count;
sync_fifo Sync_Fifo(
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
    #20;
    rst_n=1;
    @(posedge (clk));
    for (int i = 0;i<TESTS ;i++ ) begin
        wr_en=$urandom_range(0,1);
        rd_en=$urandom_range(0,1);
        wr_data=$urandom_range(0,256-1);
        $display("wr_en:%d,rd_en:%d,wr_data:%d",wr_en,rd_en,wr_data);
        @(posedge (clk));
        $display("rd_data:%d,full:%d,empty:%d,almost_full:%d,almost_empty:%d,count:%d",rd_data,full,empty,almost_full,almost_empty,count);
    end
    $stop;
end
endmodule
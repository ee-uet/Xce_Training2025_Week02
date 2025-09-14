module spi_master_tb;

    localparam DATA_WIDTH = 8;
    localparam NUM_SLAVES = 4;

    logic                      clk;
    logic                      rst_n;
    logic [DATA_WIDTH-1:0]     tx_data;
    logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
    logic                      start_transfer;
    logic                      cpol;
    logic                      cpha;
    logic [15:0]               clk_div;
    logic [DATA_WIDTH-1:0]     rx_data;
    logic                      transfer_done;
    logic                      busy;
    logic                      spi_clk;
    logic                      spi_mosi;
    logic                      spi_miso;
    logic [NUM_SLAVES-1:0]     spi_cs_n;

    always #5 clk = ~clk;

    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_SLAVES(NUM_SLAVES)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .slave_sel(slave_sel),
        .start_transfer(start_transfer),
        .cpol(cpol),
        .cpha(cpha),
        .clk_div(clk_div),
        .rx_data(rx_data),
        .transfer_done(transfer_done),
        .busy(busy),
        .spi_clk(spi_clk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs_n(spi_cs_n)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, spi_master_tb);

        clk = 0;
        rst_n = 0;
        start_transfer = 0;
        tx_data = 0;
        clk_div = 16;
        cpol = 0;
        cpha = 0;
        slave_sel = 0;
        spi_miso = 1'b0;

        #20;
        rst_n = 1;

        #20;
        tx_data = 8'hA5;
        start_transfer = 1;
        #10;
        start_transfer = 0;

        @(negedge spi_clk)
        spi_miso =  1'b1;
        @(negedge spi_clk)
        spi_miso =  1'b0;
        @(negedge spi_clk)
        spi_miso =  1'b1;
        @(negedge spi_clk)
        spi_miso =  1'b0;
        @(negedge spi_clk)
        spi_miso =  1'b1;
        @(negedge spi_clk)
        spi_miso =  1'b0;
        @(negedge spi_clk)
        spi_miso =  1'b1;

        wait (transfer_done);
        #10;

        //Mode-1
        cpha = 1'b1;
        tx_data = 8'h69;
        start_transfer = 1'b1;
        #10
        start_transfer = 1'b0;

        @(posedge spi_clk)
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;        
        @(posedge spi_clk)
        spi_miso =  1'b1;

        wait(transfer_done);
        #10;

        //Mode-2
        rst_n = 1'b0;
        #10;
        rst_n = 1'b1;
        cpol = 1'b1;
        cpha = 1'b0;
        #10;
        tx_data = 8'h99;
        start_transfer = 1'b1;
        #10;
        start_transfer = 1'b0;
        
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;
        @(posedge spi_clk)
        spi_miso =  1'b0;
        @(posedge spi_clk)
        spi_miso =  1'b1;        
        @(posedge spi_clk)
        spi_miso =  1'b1;

        wait(transfer_done);
        #10;

        $finish;
    end

endmodule

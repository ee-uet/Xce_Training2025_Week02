module tb_spi_top;
    logic        clk;
    logic        rst_n;
    logic        start_transfer;
    logic [7:0]  tx_data;
    logic [1:0]  slave_sel;
    logic [15:0] clk_div;
    logic        cpol;
    logic        cpha;
    logic        spi_clk;
    logic        mosi;
    logic        miso;
    logic [3:0]  spi_cs_n;
    logic        busy;
    logic        transfer_done;
    logic [7:0]  rx_data;

    // Instantiate DUT
    top_module UUT (
        .clk(clk),
        .rst_n(rst_n),
        .start_transfer(start_transfer),
        .tx_data(tx_data),
        .slave_sel(slave_sel),
        .clk_div(clk_div),
        .cpol(cpol),
        .cpha(cpha),
        .spi_clk(spi_clk),
        .mosi(mosi),
        .miso(miso),
        .spi_cs_n(spi_cs_n),
        .busy(busy),
        .transfer_done(transfer_done),
        .rx_data(rx_data)
    );

    // Clock generation - 50MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Simple MISO simulation
    always_ff @(posedge spi_clk or negedge rst_n) begin
        if (!rst_n)
            miso <= 0;
        else
            miso <= $random; // Random data from slave
    end

    initial begin
        // Initialize
        rst_n = 0;
        start_transfer = 0;
        tx_data = 0;
        slave_sel = 0;
        clk_div = 16'd8;  // SPI clock divider
        cpol = 0;
        cpha = 0;
        
        #50 rst_n = 1;
        #100;
        
        
    
        
        // Test 2: SPI Mode 1 (CPOL=0, CPHA=1)
        cpol = 0;
        cpha = 1;
        tx_data = 8'hAA;
        slave_sel = 2'b01;
        start_transfer = 1;
        #20 start_transfer = 0;
        
        wait(transfer_done);
        #1000;
       
        $finish;
    end

endmodule
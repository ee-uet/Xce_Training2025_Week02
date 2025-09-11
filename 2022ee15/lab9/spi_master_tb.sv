`timescale 1ns/1ps

module spi_master_tb;

    // Parameters
    localparam NUM_SLAVES  = 4;
    localparam DATA_WIDTH  = 8;

    // DUT signals
    logic clk;
    logic rst_n;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
    logic start_transfer;
    logic cpol, cpha;
    logic [15:0] clk_div;

    logic [DATA_WIDTH-1:0] rx_data;
    logic transfer_done;
    logic busy;

    logic spi_clk;
    logic spi_mosi;
    logic spi_miso;
    logic [NUM_SLAVES-1:0] spi_cs_n;

    // Instantiate DUT
    spi_master #(
        .NUM_SLAVES(NUM_SLAVES),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
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

    // -----------------------------
    // Clock generation
    // -----------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // -----------------------------
    // Simple Slave Model
    // (Just loop MOSI back to MISO)
    // -----------------------------
    assign spi_miso = spi_mosi;

    // -----------------------------
    // Test sequence
    // -----------------------------
    initial begin
        // Init
        rst_n = 0;
        start_transfer = 0;
        tx_data = 0;
        slave_sel = 0;
        cpol = 0;
        cpha = 0;
        clk_div = 4;   // slower SPI clock

        #20 rst_n = 1;

        // -----------------
        // Test Slave 0: Mode 00
        // -----------------
        @(posedge clk);
        tx_data = 8'hA5;
        slave_sel = 0;
        cpol = 0; cpha = 0; // Mode 00
        start_transfer = 1;
        @(posedge clk) start_transfer = 0;
        wait(transfer_done);
        $display("Slave 0 (Mode 00) TX=%h RX=%h", tx_data, rx_data);

        // -----------------
        // Test Slave 1: Mode 01
        // -----------------
        @(posedge clk);
        tx_data = 8'h3C;
        slave_sel = 1;
        cpol = 0; cpha = 1; // Mode 01
        start_transfer = 1;
        @(posedge clk) start_transfer = 0;
        wait(transfer_done);
        $display("Slave 1 (Mode 01) TX=%h RX=%h", tx_data, rx_data);

        // -----------------
        // Test Slave 2: Mode 10
        // -----------------
        @(posedge clk);
        tx_data = 8'h5A;
        slave_sel = 2;
        cpol = 1; cpha = 0; // Mode 10
        start_transfer = 1;
        @(posedge clk) start_transfer = 0;
        wait(transfer_done);
        $display("Slave 2 (Mode 10) TX=%h RX=%h", tx_data, rx_data);

        // -----------------
        // Test Slave 3: Mode 11
        // -----------------
        @(posedge clk);
        tx_data = 8'hF0;
        slave_sel = 3;
        cpol = 1; cpha = 1; // Mode 11
        start_transfer = 1;
        @(posedge clk) start_transfer = 0;
        wait(transfer_done);
        $display("Slave 3 (Mode 11) TX=%h RX=%h", tx_data, rx_data);

        #50;
        $finish;
    end

endmodule

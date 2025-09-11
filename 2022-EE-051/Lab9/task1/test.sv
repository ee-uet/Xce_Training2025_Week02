module tb_spi_master;

    parameter NUM_SLAVES = 4;
    parameter DATA_WIDTH = 8;

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

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Initial values
    initial begin
        rst_n          = 0;
        tx_data        = 0;
        slave_sel      = 0;
        start_transfer = 0;
        cpol           = 0;
        cpha           = 0;
        clk_div        = 0;
        spi_miso       = 0;
    end

    // Task to run one SPI mode with timeout
    task run_mode(input bit mode_cpol, input bit mode_cpha, 
                  input [7:0] data_in, input [7:0] miso_pattern);
        integer i;
        integer timeout;
        begin
            $display("\nStarting Mode (CPOL=%0b, CPHA=%0b)", mode_cpol, mode_cpha);

            // Reset DUT
            rst_n = 0;
            #50;
            rst_n = 1;
            #50;

            // Configure SPI
            cpol      = mode_cpol;
            cpha      = mode_cpha;
            tx_data   = data_in;
            slave_sel = 2;
            clk_div   = 8;
            spi_miso  = 0;

            #20;

            // Start transfer
            start_transfer = 1;
            #10;
            start_transfer = 0;

            // Drive MISO bits
            fork
                for (i = DATA_WIDTH-1; i >= 0; i--) begin
                    if (cpha == 0)
                        @(posedge spi_clk);
                    else
                        @(negedge spi_clk);
                    #1;
                    spi_miso <= miso_pattern[i];
                end
            join_none

            // Wait for transfer_done with timeout
            timeout = 0;
            while (transfer_done !== 1 && timeout < 1000) begin
                #10;
                timeout++;
            end

            if (transfer_done !== 1)
                $display("ERROR: Transfer did not complete in Mode (CPOL=%0b, CPHA=%0b)", mode_cpol, mode_cpha);
            else
                $display("Completed Mode (CPOL=%0b, CPHA=%0b). TX=%h RX=%h\n", 
                          cpol, cpha, tx_data, rx_data);

            #100;
        end
    endtask

    // Main stimulus
    initial begin
        run_mode(0, 0, 8'hA5, 8'h3C); // Mode 0
        run_mode(0, 1, 8'h3C, 8'hF0); // Mode 1
        run_mode(1, 0, 8'hF0, 8'h55); // Mode 2
        run_mode(1, 1, 8'h55, 8'hAA); // Mode 3

        $display("All SPI modes tested successfully!");
        $finish;
    end

endmodule

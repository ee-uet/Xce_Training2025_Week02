module spi_master_tb;

    // Parameters
    parameter int NUM_SLAVES = 4;
    parameter int DATA_WIDTH = 8;

    // Testbench signals
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

    typedef enum logic [1:0] { IDLE, SETUP, TRANSFER, COMPLETE } spi_state;

    // DUT instance
    spi_master dut (
        .*
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // Main stimulus
    initial begin
        @(posedge rst_n);

        // simple test cases with different CPOL/CPHA
        run_test(8'hA5, 0, 0);
        run_test(8'h3C, 0, 1);
        run_test(8'hF0, 1, 0);
        run_test(8'h5A, 1, 1);

        $display("All tests passed!");
        $finish;
    end

    // Simple test task
    task run_test(input logic [DATA_WIDTH-1:0] data,
                  input logic cpol_in,
                  input logic cpha_in);
        logic [DATA_WIDTH-1:0] received;

        // configure
        slave_sel      = 0;
        cpol           = cpol_in;
        cpha           = cpha_in;
        clk_div        = 4;
        tx_data        = data;
        spi_miso       = 0;
        start_transfer = 1;
        @(posedge clk);
        start_transfer = 0;

        // shift bits in/out
        for (int i = DATA_WIDTH-1; i >= 0; i--) begin
            if (cpha == 0) @(posedge spi_clk); else @(negedge spi_clk);
            spi_miso = data[i];             // drive MISO with same data
            received[i] = spi_mosi;         // capture MOSI
        end

        // wait for completion
        @(posedge clk);
        wait (!busy);

        // check results
        if (rx_data !== data || received !== data) begin
            $error("FAIL (CPOL=%0d, CPHA=%0d): sent=%0h, MOSI=%0h, RX=%0h",
                   cpol, cpha, data, received, rx_data);
            $stop;
        end else begin
            $display("PASS (CPOL=%0d, CPHA=%0d): data=%0h",
                     cpol, cpha, data);
        end
    endtask

endmodule

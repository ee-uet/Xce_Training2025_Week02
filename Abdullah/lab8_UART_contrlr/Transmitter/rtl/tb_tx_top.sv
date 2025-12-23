`timescale 1ns/1ps

module tb_tx_top;

    // Testbench signals
    logic clk;
    logic rst;
    logic wr_en;
    logic [7:0] wr_data;
    logic tx;
    logic [3:0] count;

    // DUT instantiation
    tx_top dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .tx(tx),
        .count(count)
    );

    // Clock generation: 50MHz (20ns period)
    always #10 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        wr_en = 0;
        wr_data = 0;

        // Apply reset
        rst = 0;
        wr_en = 0;
        wr_data = 8'h00;
        #100;       // hold reset for 100ns
        rst = 1;

        // Wait for first baud tick before writing
        wait(dut.baud.tick_tx == 1'b1);
        $display("[%0t] First baud tick detected!", $time);

        // Write few bytes to FIFO
        @(posedge clk);
        wr_en   = 1;
        wr_data = 8'hFF;    // first data
        @(posedge clk);
        wr_data = 8'h3C;    // second data
        @(posedge clk);
        wr_data = 8'hF0;    // third data
        @(posedge clk);
        wr_en   = 0;

        // Wait for transmission - much longer to see multiple baud ticks
        repeat (11000) @(posedge clk);

        $finish;
    end

    // Monitor baud ticks
    always @(posedge clk) begin
        if (dut.baud.tick_tx) begin
            $display("[%0t] TX BAUD TICK detected! count_tx = %0d", $time, dut.baud.count_tx);
        end
        if (dut.baud.tick_rx) begin
            $display("[%0t] RX BAUD TICK detected! count_rx = %0d", $time, dut.baud.count_rx);
        end
    end

    // Monitor counter values when they approach tick
    always @(posedge clk) begin
        if (dut.baud.count_tx == dut.baud.BAUD_DIVISOR_TX-2) begin
            $display("[%0t] TX counter almost at tick: %0d", $time, dut.baud.count_tx);
        end
        if (dut.baud.count_rx == dut.baud.BAUD_DIVISOR_RX-2) begin
            $display("[%0t] RX counter almost at tick: %0d", $time, dut.baud.count_rx);
        end
    end

    // Main monitor
    initial begin
        $monitor("[%0t] rst=%0b wr_en=%0b wr_data=0x%0h tx=%0b count=%0d",
                  $time, rst, wr_en, wr_data, tx, count);
    end

    // Dump waveforms for GTKWave or similar
    initial begin
        $dumpfile("tb_tx_top.vcd");
        $dumpvars(0, tb_tx_top);
        // Also dump baud rate generator signals
        $dumpvars(1, dut.baud);
    end

endmodule
module top_module_tb;
    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 25_000_000;

    logic clk;
    logic rst_n;
    logic tx_valid;
    logic [7:0] tx_data;
    logic tx_serial;
    logic tx_ready;
    logic tx_busy;

    // DUT instantiation
    Top #(
        .CLK_FREQ   (CLK_FREQ),
        .BAUD_RATE  (BAUD_RATE)
    ) uart_tx (
        .clk        (clk),
        .rst_n      (rst_n),
        .tx_valid   (tx_valid),
        .tx_data    (tx_data),
        .tx_serial  (tx_serial),
        .tx_ready   (tx_ready),
        .tx_busy    (tx_busy)
    );
    
    // 50 MHz input clock
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        // reset
        rst_n    = 0;
        tx_valid = 0;
        tx_data  = 8'h00;
        #50;
        rst_n    = 1;

        // Send a byte
        @(posedge clk);
        tx_data  = 8'hA5;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

        // Wait while busy
        wait(tx_ready);
        #200;

        // Send another byte
        @(posedge clk);
        tx_data  = 8'h3C;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

        wait(tx_ready);
        #200;

        $finish;
    end
endmodule

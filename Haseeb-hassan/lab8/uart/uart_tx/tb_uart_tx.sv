module tb_uart_tx;
    logic        clk;
    logic        rst_n;
    logic        tx_valid;
    logic [7:0]  tx_data;
    logic        tx_serial;
    logic        tx_ready;
    logic        tx_busy;

    // Instantiate DUT
    top_module UUT (
        .clk(clk),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .tx_ready(tx_ready),
        .tx_busy(tx_busy)
    );

    // Clock generation - 50MHz
    initial clk = 0;
    always #1 clk = ~clk;

    initial begin
        // Initialize
        rst_n = 0;
        tx_valid = 0;
        tx_data = 0;
        
        #50 rst_n = 1;
        #100;
        
        // Wait for ready
        wait(tx_ready);
        #20;
        
        // Send first byte
        tx_data = 8'h55;  // 01010101
        tx_valid = 1;
        #20 tx_valid = 0;
        
        // Wait for transmission to complete
        wait(tx_ready);
        #50000;
        
        
        $finish;
    end

endmodule
module tb_uart_tx;

    localparam int CLK_FREQ     = 50_000_000;   
    localparam int BAUD_RATE    = 115200;
    localparam int FIFO_DEPTH   = 16;

    logic clk;
    logic rst_n;
    logic [7:0] tx_data;
    logic       wr_en;
    logic       tx_serial;
    logic       busy;
    logic       fifo_full;
    logic       fifo_empty;
    logic       tx_ready;

    // Clock generation: 100 ns period = 10 MHz
    initial clk = 0;
    always #50 clk = ~clk;  

    // DUT instantiation
    uart_tx #(
        .WIDTH(8),
        .DEPTH(FIFO_DEPTH),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .PARITY_MODE(2)   // 0=None, 1=Even, 2=Odd
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .wr_en     (wr_en),
        .tx_data   (tx_data),
        .tx_serial (tx_serial),
        .busy      (busy),
        .fifo_full (fifo_full),
        .fifo_empty(fifo_empty),
        .tx_ready  (tx_ready)
    );

    // Stimulus
    initial begin
        rst_n   = 0;
        tx_data = 0;
        wr_en   = 0;
        #200;
        rst_n   = 1;

        // Send bytes
        @(posedge clk);
        tx_data = 8'hA5;  wr_en = 1;
        @(posedge clk);   wr_en = 0;
        // Wait for FIFO empty and transmission done
        wait(fifo_empty);
        wait(!busy);

      #20000000;
        $stop;
    end

endmodule
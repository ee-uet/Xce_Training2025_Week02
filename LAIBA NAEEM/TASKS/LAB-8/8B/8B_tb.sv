module tb_uart_rx;

    localparam int CLK_FREQ     = 50_000_000;   
    localparam int BAUD_RATE    = 115200;
    localparam int FIFO_DEPTH   = 16;
    localparam int DATA_BITS    = 8;

    real BAUD_PERIOD = 1e9 / BAUD_RATE;  // Bit period in ns

    logic clk;
    logic rst_n;
    logic rx;
    logic rd_en;
    logic [DATA_BITS-1:0] rx_out;
    logic rx_valid;
    logic fifo_empty, fifo_full;
    logic frame_error;

    // Clock generation: 50 MHz → 20 ns period
    initial clk = 0;
    always #10 clk = ~clk;

    // DUT instantiation
    uart_rx #(
        .DATA_BITS (DATA_BITS),
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (rx),
        .rd_en     (rd_en),
        .rx_out    (rx_out),
        .rx_valid  (rx_valid),
        .fifo_empty(fifo_empty),
        .fifo_full (fifo_full),
        .frame_error(frame_error)
    );

    // Stimulus
    initial begin
        rst_n = 0;
        rx    = 1;  // idle high
        rd_en = 0;
        #100;
        rst_n = 1;

        // Send first byte: 0xA5
        rx = 0; #BAUD_PERIOD;                  // Start bit
        rx = 1; #BAUD_PERIOD;                  // Bit 0 (LSB)
        rx = 0; #BAUD_PERIOD;                  // Bit 1
        rx = 1; #BAUD_PERIOD;                  // Bit 2
        rx = 0; #BAUD_PERIOD;                  // Bit 3
        rx = 1; #BAUD_PERIOD;                  // Bit 4
        rx = 1; #BAUD_PERIOD;                  // Bit 5
        rx = 1; #BAUD_PERIOD;                  // Bit 6
        rx = 1; #BAUD_PERIOD;                  // Bit 7 (MSB)
        rx = 1; #BAUD_PERIOD;                  // Stop bit

        // Wait for FIFO to register the byte
        #BAUD_PERIOD;
        #BAUD_PERIOD;

        // Read the byte from RX FIFO
        rd_en = 1; @(posedge clk);
        rd_en = 0; @(posedge clk);

        // Stop simulation after some time
        #100000;
        $stop;
    end

    // Display received data
    always @(posedge clk) begin
        if (rx_valid)
            $display("Time=%0t  RX got: %02h", $time, rx_out);
        if (frame_error)
            $display("Time=%0t  Frame Error!", $time);
    end

endmodule

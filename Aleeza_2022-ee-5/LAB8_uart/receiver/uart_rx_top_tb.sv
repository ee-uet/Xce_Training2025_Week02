module uart_rx_top_tb;

    // Clock and Reset
    logic clk;
    logic reset_n;

    // TB-driven inputs
    logic [9:0] data_in;         // 10-bit UART sampled data window from TB
    logic data_available;        // TB signals data is ready
    logic start_rx;              // TB pulses this to start RX
    logic wr_en;                 // TB pulses this to write into FIFO

    // DUT outputs
    wire [7:0] rx_data_out;      // Received data byte from DUT
    wire rx_done;                // Indicates RX complete
    wire fifo_full;

    // Clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate DUT
    uart_rx_top dut (
        .clk           (clk),
        .reset_n       (reset_n),
        .data_in       (data_in),        // from TB
        .data_available(data_available), // from TB
        .start_rx      (start_rx),       // from TB
        .wr_en         (wr_en),          // from TB

        // DUT outputs
        .rx_data_out   (rx_data_out),    // byte captured
        .rx_done       (rx_done),
        .fifo_full     (fifo_full)
    );

    // Stimulus
    initial begin
        // --- Initialize all inputs ---
        reset_n        = 0;
        data_in        = 10'b0;
        data_available = 0;
        start_rx       = 0;
        wr_en          = 0;

        // --- Apply reset ---
        #20 reset_n = 1;


        data_in        = 10'b0101010101; // TB gives UART bits
        data_available = 1;              // TB asserts data ready

        // --- Pulse start_rx to begin RX in DUT ---
        start_rx = 1;


        // --- After some clock cycles, request FIFO write ---
        repeat (5) @(posedge clk);       // wait a few cycles
        wr_en = 1;                       // TB pulses write enable

        // --- Wait for RX completion ---
        wait (rx_done);
        $display("RX completed: data_out=%h", rx_data_out);

        // --- End simulation ---
        #100;
        $stop;
    end

endmodule


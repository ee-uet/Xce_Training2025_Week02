module tb_uart_rx;

    // Parameters
    localparam int DATA_BITS       = 8;
    localparam int BAUD_TICK_COUNT = 16;   
    localparam int FIFO_DEPTH      = 16;

    // Clock period
    localparam CLK_PERIOD = 10; // 100 MHz

    // DUT signals
    logic clk, rst_n;
    logic rx;
    logic rd_en;
    logic [DATA_BITS-1:0] rx_out;
    logic rx_valid;
    logic fifo_empty, fifo_full;

    // Instantiate DUT
    uart_rx #(
        .DATA_BITS(DATA_BITS),
        .BAUD_TICK_COUNT(BAUD_TICK_COUNT),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rd_en(rd_en),
        .rx_out(rx_out),
        .rx_valid(rx_valid),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task: send one UART frame
    task send_uart_byte(input [7:0] data);
        int i;
        begin
            // Start bit
            rx = 1'b0;
            repeat (BAUD_TICK_COUNT) @(posedge clk);

            // Data bits (LSB first)
            for (i = 0; i < DATA_BITS; i++) begin
                rx = data[i];
                repeat (BAUD_TICK_COUNT) @(posedge clk);
            end

            // Stop bit
            rx = 1'b1;
            repeat (BAUD_TICK_COUNT) @(posedge clk);
        end
    endtask

    // Stimulus
    initial begin
        clk   = 0;
        rst_n = 0;
        rx    = 1;  // idle line high
        rd_en = 0;

        // Reset
        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // Send bytes
        send_uart_byte("A");
        send_uart_byte("B");
        send_uart_byte("C");

        // Wait
        repeat (100) @(posedge clk);

        // Read from FIFO
        repeat (3) begin
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
            @(posedge clk);
            $display("RX got byte: %h (%c)", rx_out, rx_out);
        end

        repeat (20) @(posedge clk);
        $finish;
    end

endmodule

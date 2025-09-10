module tb_uart_rx;

    localparam int CLK_FREQ     = 50_000_000;   
    localparam int BAUD_RATE    = 115200;
    localparam int FIFO_DEPTH   = 16;
    localparam int DATA_BITS    = 8;

    localparam real CLK_PERIOD  = 20; // 50 MHz → 20 ns
    localparam int BAUD_TICK    = CLK_FREQ / BAUD_RATE;
    localparam real BAUD_PERIOD = CLK_PERIOD * BAUD_TICK;

    logic clk;
    logic rst_n;
    logic rx;
    logic rd_en;
    logic [DATA_BITS-1:0] rx_out;
    logic rx_valid;
    logic fifo_empty, fifo_full;
    logic frame_error;

    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

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

    // Task: send 1 UART byte
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // start bit
            rx = 0; #(BAUD_PERIOD);
            // data bits (LSB first)
            for (i = 0; i < DATA_BITS; i++) begin
                rx = data[i]; #(BAUD_PERIOD);
            end
            // stop bit
            rx = 1; #(BAUD_PERIOD);
        end
    endtask

    // Stimulus
    initial begin
        rx    = 1;  // idle high
        rd_en = 0;
        rst_n = 0;
        #(10*CLK_PERIOD);
        rst_n = 1;

        // Send three bytes
        send_uart_byte(8'hA5);
        send_uart_byte(8'h3C);
        send_uart_byte(8'hFF);

        // Wait a bit
        #(BAUD_PERIOD*15);

        // Read out bytes
        repeat (3) begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
            @(posedge clk);
        end

        #(100*CLK_PERIOD);
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

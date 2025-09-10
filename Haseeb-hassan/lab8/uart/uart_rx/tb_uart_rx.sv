module tb_uart_rx;
    logic        clk;
    logic        rst_n;
    logic        rx_serial;
    logic [7:0]  rx_data;
    logic        rx_ready;
    logic        frame_error;
    logic        rx_busy;

    // Instantiate DUT
    top_module UUT (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .frame_error(frame_error),
        .rx_busy(rx_busy)
    );

    // Clock generation - 50MHz
    initial clk = 0;
    always #1 clk = ~clk;

    // UART bit timing - same as baud rate (115200)
    localparam real BIT_TIME = 868; // nanoseconds per bit

    initial begin
        // Initialize
        rst_n = 0;
        rx_serial = 1;  // UART idle is high
        
        #50 rst_n = 1;
        #100;
        
        // Wait for ready
        wait(rx_ready);
        #20;
        
        // Send UART byte 0x55 (01010101)
        // Start bit
        rx_serial = 0;
        #BIT_TIME; //Bit Time = 1 / 115200 = 8.68 microseconds = 8680 nanoseconds
        
        // Data bits (LSB first: 1,0,1,0,1,0,1,0)
        rx_serial = 1; #BIT_TIME;  // bit 0
        rx_serial = 0; #BIT_TIME;  // bit 1
        rx_serial = 1; #BIT_TIME;  // bit 2
        rx_serial = 0; #BIT_TIME;  // bit 3
        rx_serial = 1; #BIT_TIME;  // bit 4
        rx_serial = 0; #BIT_TIME;  // bit 5
        rx_serial = 1; #BIT_TIME;  // bit 6
        rx_serial = 0; #BIT_TIME;  // bit 7
        
        // Stop bit
        rx_serial = 1;
        #BIT_TIME;
        
        // Wait for reception to complete
        wait(rx_ready);
        #50000;
        
        $finish;
    end

endmodule
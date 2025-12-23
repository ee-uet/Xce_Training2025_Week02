module uart_receiver_tb;

    // Test parameters
    localparam int CLK_FREQ = 50_000_000;
    localparam int BAUD_RATE = 115200;
    localparam int FIFO_DEPTH = 8;
    localparam bit PARITY_EN = 1;
    localparam bit PARITY_ODD = 0;
    
    // Clock period and bit period calculations
    localparam real CLK_PERIOD = 1e9 / CLK_FREQ; 
    localparam real BIT_PERIOD = 1e9 / BAUD_RATE; 
    
    // Testbench signals
    logic       clk;
    logic       rst_n;
    logic       rx_serial;
    logic       rx_read;
    logic [7:0] rx_data;
    logic       rx_valid;
    logic       rx_error;
    logic       rx_busy;
    logic       rx_frame_error;
    logic       rx_parity_error;
    logic       fifo_full;
    logic       fifo_empty;

    // DUT instantiation
    uart_receiver #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH),
        .PARITY_EN(PARITY_EN),
        .PARITY_ODD(PARITY_ODD)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .rx_read(rx_read),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error),
        .rx_busy(rx_busy),
        .rx_frame_error(rx_frame_error),
        .rx_parity_error(rx_parity_error),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Simple UART transmit procedure
    task send_uart_byte(input [7:0] data);
        automatic logic parity_bit;
        
        // Calculate even parity
        parity_bit = ^data;
        
        $display("Time %0t: Sending byte 0x%02X", $time, data);
        
        // Start bit
        rx_serial = 1'b0;
        #(BIT_PERIOD);
        
        // Data bits (LSB first)
        for (int i = 0; i < 8; i++) begin
            rx_serial = data[i];
            #(BIT_PERIOD);
        end
        
        // Parity bit (if enabled)
        if (PARITY_EN) begin
            rx_serial = parity_bit;
            #(BIT_PERIOD);
        end
        
        // Stop bit
        rx_serial = 1'b1;
        #(BIT_PERIOD);
        
        $display("Time %0t: Byte transmission complete", $time);
    endtask

    // Simple read procedure
    task read_fifo();
        wait(rx_valid);
        rx_read = 1'b1;
        @(posedge clk);
        rx_read = 1'b0;
        $display("Time %0t: Read data=0x%02X, error=%b, frame_error=%b, parity_error=%b", 
                 $time, rx_data, rx_error, rx_frame_error, rx_parity_error);
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 1'b0;
        rx_serial = 1'b1; // UART idle state
        rx_read = 1'b0;
        
        // Reset
        #(10 * CLK_PERIOD);
        rst_n = 1'b1;
        #(10 * CLK_PERIOD);
        
        $display("=== UART Receiver Test Started ===");
        
        // Test 1: Send valid byte
        $display("\n--- Test 1: Valid byte transmission ---");
        send_uart_byte(8'hA5);
        read_fifo();
        
        // Test 2: Send another valid byte
        $display("\n--- Test 2: Another valid byte ---");
        send_uart_byte(8'h3C);
        read_fifo();
        
        // Test 3: Send multiple bytes quickly
        $display("\n--- Test 3: Multiple bytes ---");
        send_uart_byte(8'h11);
        send_uart_byte(8'h22);
        send_uart_byte(8'h33);
        
        // Read all three
        read_fifo();
        read_fifo();
        read_fifo();
        
        // Test 4: Frame error (corrupted stop bit)
        $display("\n--- Test 4: Frame error test ---");
        rx_serial = 1'b0; // Start bit
        #(BIT_PERIOD);
        
        // Send data byte 0x55
        for (int i = 0; i < 8; i++) begin
            rx_serial = (8'h55 >> i) & 1'b1;
            #(BIT_PERIOD);
        end
        
        // Send parity
        if (PARITY_EN) begin
            rx_serial = ^(8'h55);
            #(BIT_PERIOD);
        end
        
        // Corrupted stop bit (should be 1, but send 0)
        rx_serial = 1'b0;
        #(BIT_PERIOD);
        
        // Return to idle
        rx_serial = 1'b1;
        #(BIT_PERIOD);
        
        read_fifo();
        
        // Wait and finish
        #(20 * BIT_PERIOD);
        
        $display("\n=== Test Complete ===");
        $display("Final FIFO status: empty=%b, full=%b", fifo_empty, fifo_full);
        
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor("Time %0t: busy=%b, valid=%b, empty=%b, full=%b", 
                 $time, rx_busy, rx_valid, fifo_empty, fifo_full);
    end

endmodule
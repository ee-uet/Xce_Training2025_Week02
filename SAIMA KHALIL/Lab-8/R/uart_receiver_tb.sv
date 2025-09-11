`timescale 1ns/1ps

module uart_receiver_tb;
 
  // DUT I/O
  logic clk;
  logic rst;
  logic rx_serial;
  logic rx_ready;
  logic [7:0] rx_data;
  logic rx_valid;
  logic frame_error;
  logic baud_clk;

  // Instantiate DUT
  uart_receiver  dut (
      .clk        (clk),
      .rst        (rst),          // ✅ changed to rst
      .rx_serial  (rx_serial),
      .rx_ready   (rx_ready),
      .rx_data    (rx_data),
      .rx_valid   (rx_valid),
      .frame_error(frame_error),
      .baud_clk (baud_clk)    // ✅ changed to baud_clk
  );

  // Clock generation (20 ns => 50 MHz)
  initial clk = 0;
  always #10 clk = ~clk;

  // Test procedure
  initial begin
    // Init
    rst       = 1;      // ✅ active-high reset
    rx_serial = 1;      // idle line = 1
    rx_ready  = 0;

    // Reset sequence
    #100;
    rst = 0;
    #100;

    // Wait a little for baud clock
    repeat (5) @(posedge baud_clk);

    // === Send byte 0xA5 = 1010_0101 ===
    $display("[%0t] Sending byte 0xA5 ...", $time);

    // Start bit
    rx_serial = 0;
    @(posedge baud_clk);

    // Data bits (LSB first: 1,0,1,0,0,1,0,1)
    rx_serial = 1; @(posedge baud_clk);
    rx_serial = 0; @(posedge baud_clk);
    rx_serial = 1; @(posedge baud_clk);
    rx_serial = 0; @(posedge baud_clk);
    rx_serial = 0; @(posedge baud_clk);
    rx_serial = 1; @(posedge baud_clk);
    rx_serial = 0; @(posedge baud_clk);
    rx_serial = 1; @(posedge baud_clk);

    // Stop bit
    rx_serial = 1;
    @(posedge baud_clk);

    // === Wait for DUT ===
    wait(rx_valid);
    $display("[%0t] Received: %h (frame_error=%b)", $time, rx_data, frame_error);

    // Acknowledge 
    rx_ready = 1;

    #2000;
    $display("[%0t] Simulation finished.", $time);
    $stop;
  end

endmodule

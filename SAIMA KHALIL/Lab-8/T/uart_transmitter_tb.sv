module uart_transmitter_tb;

  // Parameters
  localparam CLK_FREQ   = 50000000;
  localparam BAUD_RATE  = 115200;
  localparam FIFO_DEPTH = 8;

  // DUT I/O
  logic clk;
  logic rst_n;
  logic [7:0] tx_data;
  logic tx_valid;
  logic tx_ready;
  logic tx_serial;
  logic tx_busy;
  logic baud_tick;

  // Instantiate DUT
  uart_transmitter #(
      .CLK_FREQ(CLK_FREQ),
      .BAUD_RATE(BAUD_RATE),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
      .clk       (clk),
      .rst_n     (rst_n),
      .tx_data   (tx_data),
      .tx_valid  (tx_valid),
      .tx_ready  (tx_ready),
      .tx_serial (tx_serial),
      .baud_tick(baud_tick),
      .tx_busy   (tx_busy)
  );

  // Clock generation (20ns => 50 MHz)
  always #10 clk = ~clk;

  // Test procedure
  initial begin
    // Initial values
    clk      = 0;
    rst_n    = 0;
    tx_data  = 8'h00;
    tx_valid = 0;

    rst_n = 0;           // reset inactive
    #20;
    rst_n = 1;           // reset active
    #20;
    rst_n = 0;           // reset release

    // Send only one byte
    @(posedge baud_tick);
    tx_data  = 8'hAD;   // 0100 1110
    tx_valid = 1;
    @(posedge baud_tick);
    tx_valid = 0;
    $display("[%0t] Sent byte: 0x%0h",$time, tx_data);

    // Wait to complete transmission
    wait (tx_ready);
    #5000;

    // Finish simulation
    $display("[%0t] Simulation finished",$time);
    $stop;
  end

endmodule

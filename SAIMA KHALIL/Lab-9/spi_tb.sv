module spi_tb;

  parameter DATA_WIDTH = 8;
  parameter NUM_SLAVES = 4;

  // Signals
  logic clk;
  logic rst_n;
  logic start_transfer;
  logic [DATA_WIDTH-1:0] tx_data;
  logic [DATA_WIDTH-1:0] rx_data;
  logic transfer_done;
  logic busy;

  logic spi_clk;
  logic spi_mosi;
  logic spi_miso;
  logic [NUM_SLAVES-1:0] spi_cs_n;

  logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
  logic cpol, cpha;
  logic [15:0] clk_div;
 
  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  

  // DUT
  spi1 #(
    .NUM_SLAVES(NUM_SLAVES),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .start_transfer(start_transfer),
    .transfer_done(transfer_done),
    .busy(busy),
    .slave_sel(slave_sel),
    .cpol(cpol),
    .cpha(cpha),
    .clk_div(clk_div),
    .spi_clk(spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_cs_n(spi_cs_n)
  );

  // Slave signals
  logic [DATA_WIDTH-1:0] slave_shift_tx;
  logic [DATA_WIDTH-1:0] slave_shift_rx;
  logic [DATA_WIDTH-1:0] slave_response = 8'h3C;

  logic spi_clk_prev;
  logic rising_edge, falling_edge;
  logic leading_edge, trailing_edge;
  logic sample_edge, shift_edge;

  // Previous clock for edge detection
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      spi_clk_prev <= cpol;
    else
      spi_clk_prev <= spi_clk;
  end

  assign rising_edge  = (spi_clk_prev==0 && spi_clk==1);
  assign falling_edge = (spi_clk_prev==1 && spi_clk==0);

  // Determine leading/trailing edges based on CPOL
  assign leading_edge  = (cpol == 0) ? rising_edge  : falling_edge;
  assign trailing_edge = (cpol == 0) ? falling_edge : rising_edge;

  // Sample/shift edges based on CPHA
  assign sample_edge = (cpha == 0) ? leading_edge  : trailing_edge;
  assign shift_edge  = (cpha == 0) ? trailing_edge : leading_edge;

  // Slave logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      slave_shift_tx <= '0;
      slave_shift_rx <= '0;
    end else begin
      if (spi_cs_n[slave_sel] == 1'b1) begin
        // CS inactive: preload response, clear RX
        slave_shift_tx <= slave_response;
        slave_shift_rx <= '0;
      end else begin
        // CS active: normal shift/sample
        if (shift_edge)
          slave_shift_tx <= {slave_shift_tx[DATA_WIDTH-2:0], 1'b0};
        if (sample_edge)
          slave_shift_rx <= {slave_shift_rx[DATA_WIDTH-2:0], spi_mosi};
      end
    end
  end

  // Slave drives MISO only when selected
  assign spi_miso = (!spi_cs_n[slave_sel]) ? slave_shift_tx[DATA_WIDTH-1] : 1'bz;

  // Task to perform SPI transfer
  task do_transfer(input [7:0] data, input bit CPOL, input bit CPHA);
    begin
      cpol = CPOL;
      cpha = CPHA;

      @(posedge clk);
      tx_data = data;
      slave_sel = 0;
      start_transfer = 1;
      @(posedge clk);
      start_transfer = 0;

      wait (transfer_done);
      $display("Time=%0t: Transfer Complete (CPOL=%0d, CPHA=%0d)", $time, CPOL, CPHA);
      $display("  Master sent: 0x%h, Master received: 0x%h", tx_data, rx_data);
      $display("  Slave captured: 0x%h", slave_shift_rx);
    end
  endtask

  // Test sequence
  initial begin
    rst_n = 0;
    start_transfer = 0;
    tx_data = 0;
    slave_sel = 0;
    clk_div = 4;

    #100;
    rst_n = 1;
    #20;

    // Run all 4 SPI modes
    do_transfer(8'hA5, 0, 0); // Mode 0
    #50;
    do_transfer(8'h3C, 0, 1); // Mode 1
    #50;
    do_transfer(8'h5A, 1, 0); // Mode 2
    #50;
    do_transfer(8'hC3, 1, 1); // Mode 3

    #100;
    $display("Simulation completed successfully!");
    $finish;
  end

  // Monitoring
  always @(posedge transfer_done) begin
    $display("Transfer done detected at time %0t", $time);
  end

  always @(posedge busy) begin
    $display("Busy asserted at time %0t", $time);
  end

endmodule

`timescale 1ns/1ps

module spi_master_tb;

  // Parameters
  localparam int NUM_SLAVES  = 4;
  localparam int DATA_WIDTH  = 8;

  // DUT signals
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] tx_data;
  logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
  logic start_transfer;
  logic cpol, cpha;
  logic [15:0] clk_div;

  logic [DATA_WIDTH-1:0] rx_data;
  logic transfer_done;
  logic busy;
  logic spi_clk;
  logic spi_mosi;
  logic spi_miso;
  logic [NUM_SLAVES-1:0] spi_cs_n;

  // Instantiate DUT
  spi_master #(
      .NUM_SLAVES(NUM_SLAVES),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .tx_data(tx_data),
      .slave_sel(slave_sel),
      .start_transfer(start_transfer),
      .cpol(cpol),
      .cpha(cpha),
      .clk_div(clk_div),
      .rx_data(rx_data),
      .transfer_done(transfer_done),
      .busy(busy),
      .spi_clk(spi_clk),
      .spi_mosi(spi_mosi),
      .spi_miso(spi_miso),
      .spi_cs_n(spi_cs_n)
  );

  // -------------------
  // Clock generation
  // -------------------
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock (10 ns period)

  // -------------------
  // ** FINAL CORRECTED SPI SLAVE MODEL **
  // -------------------
  logic [DATA_WIDTH-1:0] slave_tx_reg = 8'hA5; // Data slave will send
  logic [DATA_WIDTH-1:0] slave_rx_reg;       // Data slave will receive

  // For Mode 0, slave samples incoming data on the RISING edge of spi_clk.
  always @(posedge spi_clk or negedge spi_cs_n[0]) begin
      if(!spi_cs_n[0]) begin
          slave_rx_reg <= {slave_rx_reg[DATA_WIDTH-2:0], spi_mosi};
      end
  end

  // For Mode 0, slave drives outgoing data on the FALLING edge of spi_clk.
  // This gives the data time to be stable before the master samples it on the next rising edge.
  always @(negedge spi_clk or negedge spi_cs_n[0]) begin
      if(!spi_cs_n[0]) begin
          spi_miso <= slave_tx_reg[DATA_WIDTH-1];
          slave_tx_reg <= {slave_tx_reg[DATA_WIDTH-2:0], 1'b0};
      end else begin
          spi_miso     <= 1'bz;   // High-impedance when not selected
          slave_tx_reg <= 8'hA5;  // Reload shift register for the next transfer
      end
  end


  // -------------------
  // Stimulus
  // -------------------
  initial begin
    // Initialize
    rst_n = 0;
    tx_data = 8'h3C;  // Master will send 0x3C
    slave_sel = 0;
    start_transfer = 0;
    cpol = 0;
    cpha = 0;
    clk_div = 4;  // Slow SPI clock for visibility

    // Reset
    #50;
    rst_n = 1;

    // Start transfer
    #20;
    start_transfer = 1;
    #10;
    start_transfer = 0;

    // Wait until transfer is done
    wait (transfer_done);
    #20;

    $display("----------------------------------------");
    $display("Master sent:     0x%h", tx_data);
    $display("Master received: 0x%h (Expected 0xA5)", rx_data);
    $display("Slave received:  0x%h (Expected 0x3C)", slave_rx_reg);
    $display("----------------------------------------");
    
    // Verification check
    if(rx_data === 8'hA5) begin
        $display("SUCCESS: Master received the correct data.");
    end else begin
        $error("FAILURE: Master received incorrect data.");
    end

    #100;
    $finish;
  end

endmodule


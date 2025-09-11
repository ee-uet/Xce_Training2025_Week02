module uart_tx_top_tb;

    // DUT inputs
    logic clk;
    logic reset_n;
    logic wr_en;
    logic [7:0] wr_data;
    logic data_available;   // added
    logic tx_valid;         // added

    // DUT outputs
    wire tx_serial;
    wire tx_busy;
    wire tx_done;
    wire frame_error;

    // Clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate DUT
    uart_tx_top dut (
        .clk           (clk),
        .reset_n       (reset_n),
        .wr_en         (wr_en),
        .wr_data       (wr_data),
        .tx_serial     (tx_serial),
        .tx_busy       (tx_busy),
        .tx_done       (tx_done),
        .data_available(data_available),
        .tx_valid      (tx_valid),
        .frame_error   (frame_error)
    );

    // Stimulus
    initial begin
        // init signals
        reset_n        = 0;
        wr_en          = 0;
        wr_data        = 8'h00;
        data_available = 0;
        tx_valid       = 0;

        // reset pulse
        #20 reset_n = 1;

        // send one byte
        wr_en = 1;
        wr_data        = 8'h55;
        data_available = 1;   // show FIFO has data
        tx_valid       = 1;   // pulse valid
        #10 tx_valid   = 0;
        // wait some time for transmission to complete
        #2000;
        
        $stop;  // end simulation
    end

endmodule


module top_module_tb;
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_RATE = 25_000_000;

    logic clk;
    logic rst_n;
    logic tx_valid;
    logic [7:0] tx_data;
    logic tx_serial;
    logic tx_ready;
    logic tx_busy;

    logic div_clk;

    clk_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) clk_gen (
        .clk(clk),
        .rst_n(rst_n),
        .div_clk(div_clk)
    );

    top_module #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .tx_serial(tx_serial),
        .tx_ready(tx_ready),
        .tx_busy(tx_busy)
    );
    
    
    initial clk = 0;
    always #10 clk = ~clk; // 50MHz clock (time_period = 20ns)

    initial begin
        
        rst_n = 0; tx_valid = 0; tx_data = 8'h00;
        #3
        rst_n = 1;
        #1
        tx_data = 8'hA5;
        tx_valid = 1;
        @(posedge div_clk);
        tx_valid = 0;
        repeat (10) @(posedge div_clk);

        // Finish simulation
        $finish;
    end

endmodule



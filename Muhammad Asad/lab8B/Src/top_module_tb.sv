module top_module_tb;
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_RATE = 25_000_000;

    logic        clk;
    logic        rst_n;
    logic        rx_serial;
    logic [7:0]  rx_data;
    logic        rx_ready;
    logic        frame_error;
    logic        rx_busy;

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
    ) uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .rx_data(rx_data),
        .frame_error(frame_error),
        .rx_ready(rx_ready),
        .rx_busy(rx_busy)
    );
    
    
    initial clk = 0;
    always #10 clk = ~clk; // 50MHz clock (time_period = 20ns)

    initial begin
        
        rst_n = 0; rx_serial = 1;
        #3
        rst_n = 1;
        @(posedge div_clk);
        rx_serial = 0;
        @(posedge div_clk);
        // sending 10100101
        rx_serial = 1;
        @(posedge div_clk);
        rx_serial = 0;
        @(posedge div_clk);
        rx_serial = 1;
        @(posedge div_clk);
        rx_serial = 0;
        @(posedge div_clk);

        rx_serial = 0;
        @(posedge div_clk);
        rx_serial = 1;
        @(posedge div_clk);
        rx_serial = 0;
        @(posedge div_clk);
        rx_serial = 1;
        @(posedge div_clk);
        rx_serial = 0;
        repeat (2) @(posedge clk);

        // Finish simulation
        $finish;
    end

endmodule



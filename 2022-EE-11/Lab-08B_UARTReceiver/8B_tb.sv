module uart_receiver_tb();

    localparam CLK_FREQ = 50_000_000;
    localparam BAUD_RATE = 115200;
    localparam FIFO_DEPTH = 24;
    localparam BAUD_TICKS = CLK_FREQ / BAUD_RATE;
    
    logic clk, rst_n;
    logic rx_serial;
    logic rx_valid, rx_ready, rx_error;
    logic [7:0] rx_data;
    
    // Test data - more than FIFO depth
    logic [7:0] test_data [40];
    
    int rx_count = 0;
    
    uart_receiver #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (.*);
    
    // Clock
    always #10 clk = ~clk;
    
    // Send UART byte
    task send_byte(logic [7:0] data, logic bad_parity = 0);
        logic parity;
        parity = ^data;
        if (bad_parity) parity = ~parity;
        
        @(posedge clk);
        rx_serial = 0; // start bit
        repeat(BAUD_TICKS) @(posedge clk);
        
        for (int i = 0; i < 8; i++) begin
            rx_serial = data[i];
            repeat(BAUD_TICKS) @(posedge clk);
        end
        
        rx_serial = parity; // parity bit
        repeat(BAUD_TICKS) @(posedge clk);
        
        rx_serial = 1; // stop bit
        repeat(BAUD_TICKS) @(posedge clk);
    endtask
    
    // Reader process
    always @(posedge clk) begin
        if (!rst_n) begin
            rx_ready <= 0;
            rx_count <= 0;
        end else begin
            rx_ready <= 0;
            
            if (rx_valid && (rx_count % (30*BAUD_TICKS) == 0)) begin // Read every 3rd cycle
                rx_ready <= 1;
                rx_count <= rx_count + 1;
                $display("Read: 0x%02h", rx_data);
            end else if (rx_valid) begin
                rx_count <= rx_count + 1;
            end
        end
    end
    
    initial begin
        clk = 0;
        rst_n = 0;
        rx_serial = 1;
        
        // Initialize test data
        test_data[0] = 8'h41; test_data[1] = 8'h42; test_data[2] = 8'h43; test_data[3] = 8'h44;
        test_data[4] = 8'h45; test_data[5] = 8'h46; test_data[6] = 8'h47; test_data[7] = 8'h48;
        test_data[8] = 8'h49; test_data[9] = 8'h4A; test_data[10] = 8'h4B; test_data[11] = 8'h4C;
        test_data[12] = 8'h4D; test_data[13] = 8'h4E; test_data[14] = 8'h4F; test_data[15] = 8'h50;
        test_data[16] = 8'h51; test_data[17] = 8'h52; test_data[18] = 8'h53; test_data[19] = 8'h54;
        test_data[20] = 8'h55; test_data[21] = 8'h56; test_data[22] = 8'h57; test_data[23] = 8'h58;
        test_data[24] = 8'h59; test_data[25] = 8'h5A; test_data[26] = 8'h30; test_data[27] = 8'h31;
        test_data[28] = 8'h32; test_data[29] = 8'h33; test_data[30] = 8'h34; test_data[31] = 8'h35;
        test_data[32] = 8'h36; test_data[33] = 8'h37; test_data[34] = 8'h38; test_data[35] = 8'h39;
        test_data[36] = 8'h40;
        
        repeat(10) @(posedge clk);
        rst_n = 1;
        repeat(10) @(posedge clk);
        
        // Send erroneous frame first
        $display("Sending bad frame...");
        send_byte(8'hAA, 1); // bad parity
        repeat(100) @(posedge clk);
        
        // Send test data
        $display("Sending 30 bytes...");
        for (int i = 0; i < 37; i++) begin
            send_byte(test_data[i]);
        end
        
        wait(dut.em_flag); 
        @(posedge clk);
        $finish;
    end
    
    initial begin
        $dumpfile("8B.vcd");
        $dumpvars;
    end
    
endmodule

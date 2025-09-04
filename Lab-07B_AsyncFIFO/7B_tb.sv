module tb_asynchronous_fifo();
    // Parameters
    parameter DEPTH = 8;
    parameter DATA_WIDTH = 8;
    parameter PTR_WIDTH = $clog2(DEPTH);
    
    // Signals
    logic wclk, wrst_n;
    logic rclk, rrst_n;
    logic w_en, r_en;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic full, empty;
    
    // Clock generation
    initial wclk = 0;
    always #10 wclk = ~wclk; // Write clock (period = 20ns)
    
    initial rclk = 0;
    always #15 rclk = ~rclk; // Read clock (period = 30ns)
    
    // Instantiate the asynchronous FIFO
    asynchronous_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );
    
    // Synchronous write task
    task write_fifo(input [DATA_WIDTH-1:0] data);
        @(posedge wclk);
        if (!full) begin
            w_en = 1;
            data_in = data;
            @(posedge wclk);
            w_en = 0;
            data_in = 0;
            $display("Time=%t: Write - Data=0x%h, Full=%b, Empty=%b", $time, data, full, empty);
        end else begin
            $display("Time=%t: Write attempted but FIFO full - Data=0x%h, Full=%b, Empty=%b", $time, data, full, empty);
        end
    endtask
    
    // Synchronous read task
    task read_fifo();
        @(posedge rclk);
        if (!empty) begin
            r_en = 1;
            @(posedge rclk);
            r_en = 0;
            $display("Time=%t: Read - Data=0x%h, Full=%b, Empty=%b", $time, data_out, full, empty);
        end else begin
            $display("Time=%t: Read attempted but FIFO empty - Full=%b, Empty=%b", $time, full, empty);
        end
    endtask
    
    // Monitor FIFO state changes
    always @(posedge wclk or posedge rclk) begin
        if (w_en || r_en) begin
            $display("Time=%t: WriteClk=%b, ReadClk=%b, WriteEn=%b, ReadEn=%b, Full=%b, Empty=%b", 
                     $time, wclk, rclk, w_en, r_en, full, empty);
        end
    end
    
    initial begin
        // Initialize VCD dump
        $dumpfile("7B.vcd");
        $dumpvars(0, tb_asynchronous_fifo);
        
        // Initialize signals
        wrst_n = 0;
        rrst_n = 0;
        w_en = 0;
        r_en = 0;
        data_in = 0;
        
        // Test 1: Synchronous reset
        @(posedge wclk);
        wrst_n = 1;
        @(posedge rclk);
        rrst_n = 1;
        @(posedge wclk);
        $display("Time=%t: Reset complete - Full=%b, Empty=%b", $time, full, empty);
        if (empty !== 1 || full !== 0)
            $display("Test 1 FAILED: Expected empty=1, full=0 after reset");
        
        // Test 2: Write until full and test full condition
        $display("Time=%t: Writing until full...", $time);
        for (int i = 0; i < DEPTH; i++) begin
            write_fifo(i);
        end
        @(posedge wclk);
        if (full !== 1)
            $display("Test 2 FAILED: Expected full=1 after %0d writes", DEPTH);
        write_fifo(8'hFF); // Attempt write when full
        if (full !== 1)
            $display("Test 2 FAILED: FIFO full condition not maintained");
        
        // Test 3: Read until empty and test empty condition
        $display("Time=%t: Reading until empty...", $time);
        for (int i = 0; i < DEPTH; i++) begin
            read_fifo();
        end
        @(posedge rclk);
        if (empty !== 1)
            $display("Test 3 FAILED: Expected empty=1 after %0d reads", DEPTH);
        read_fifo(); // Attempt read when empty
        if (empty !== 1)
            $display("Test 3 FAILED: FIFO empty condition not maintained");
        
        // Test 4: Sequential write and read to test partial fill
        $display("Time=%t: Testing sequential write and read...", $time);
        for (int i = 0; i < 4; i++) begin
            write_fifo(8'hA0 + i);
        end
        @(posedge wclk);
        if (full === 1 || empty === 1)
            $display("Test 4 FAILED: Expected partial fill (neither full nor empty)");
        for (int i = 0; i < 4; i++) begin
            read_fifo();
        end
        @(posedge rclk);
        if (empty !== 1)
            $display("Test 4 FAILED: Expected empty=1 after reading all data");
        
        // Test 5: Stress test with interleaved writes and reads
        $display("Time=%t: Stress test with interleaved writes and reads...", $time);
        for (int i = 0; i < 10; i++) begin
            if (i % 2 == 0) begin
                write_fifo(8'hB0 + i);
            end else begin
                read_fifo();
            end
            @(posedge wclk);
            @(posedge rclk);
        end
        if (full === 1 || empty === 1)
            $display("Test 5 WARNING: FIFO may be in unexpected state - Full=%b, Empty=%b", full, empty);
        
        // Test 6: Synchronous reset during operation
        $display("Time=%t: Testing reset during operation...", $time);
        write_fifo(8'hFF);
        @(posedge wclk);
        wrst_n = 0;
        @(posedge rclk);
        rrst_n = 0;
        @(posedge wclk);
        wrst_n = 1;
        @(posedge rclk);
        rrst_n = 1;
        @(posedge wclk);
        $display("Time=%t: Reset complete - Full=%b, Empty=%b", $time, full, empty);
        if (empty !== 1 || full !== 0)
            $display("Test 6 FAILED: Expected empty=1, full=0 after reset");
        read_fifo(); // Verify empty after reset
        
        // Finish simulation
        repeat(10) @(posedge wclk);
        $display("Time=%t: Test completed", $time);
        $finish;
    end
endmodule

module tb_sync_fifo();
    // Parameters
    parameter int DATA_WIDTH = 8;
    parameter int FIFO_DEPTH = 16;
    parameter int ALMOST_FULL_THRESH = 14;
    parameter int ALMOST_EMPTY_THRESH = 2;
    
    // Signals
    logic                    clk;
    logic                    rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wr_data;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rd_data;
    logic                    full;
    logic                    empty;
    logic                    almost_full;
    logic                    almost_empty;
    logic [$clog2(FIFO_DEPTH):0] count;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate the FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(count)
    );
    
    // Synchronous helper task for writing to FIFO
    task write_fifo_sync;
        input [DATA_WIDTH-1:0] data;
        begin
            @(posedge clk);
            if (!full) begin
                wr_en <= 1;
                wr_data <= data;
                @(posedge clk);
                wr_en <= 0;
                $display("Time=%t: Write - Data=0x%h, Count=%d", $time, data, count);
            end else begin
                $display("Time=%t: Write attempted but FIFO is full", $time);
            end
        end
    endtask
    
    // Synchronous helper task for reading from FIFO
    task read_fifo_sync;
        begin
            @(posedge clk);
            if (!empty) begin
                rd_en <= 1;
                @(posedge clk);
                rd_en <= 0;
                $display("Time=%t: Read - Data=0x%h, Count=%d", $time, rd_data, count);
            end else begin
                $display("Time=%t: Read attempted but FIFO is empty", $time);
            end
        end
    endtask
    
    // Check FIFO flags
    task check_flags;
        input exp_full, exp_empty;
        begin
            @(posedge clk); // Synchronize flag checking
            if (full !== exp_full) 
                $display("ERROR: Expected full=%b, got full=%b at time=%t", exp_full, full, $time);
            if (empty !== exp_empty) 
                $display("ERROR: Expected empty=%b, got empty=%b at time=%t", exp_empty, empty, $time);
            $display("Time=%t: Flags - Full=%b, Empty=%b, Count=%d", $time, full, empty, count);
        end
    endtask
    
    initial begin
        // Initialize VCD dump
        $dumpfile("7A.vcd");
        $dumpvars(0, tb_sync_fifo);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        wr_data = 0;
        rd_en = 0;
        
        // Test 1: Reset and verify empty condition
        $display("=== Test 1: Reset and Empty Condition ===");
        @(posedge clk);
        @(posedge clk);
        rst_n <= 1;
        @(posedge clk);
        $display("Time=%t: Reset complete", $time);
        check_flags(0, 1); // Should be not full and empty after reset
        
        // Test 2: Fill FIFO to full condition
        $display("=== Test 2: Fill FIFO to Full Condition ===");
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            write_fifo_sync(i);
        end
        check_flags(1, 0); // Should be full and not empty
        
        // Test 3: Try to write when full (should be blocked)
        $display("=== Test 3: Write When Full (Should Fail) ===");
        write_fifo_sync(8'hFF);
        check_flags(1, 0); // Should still be full and not empty
        
        // Test 4: Empty the FIFO completely
        $display("=== Test 4: Empty FIFO Completely ===");
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            read_fifo_sync();
        end
        check_flags(0, 1); // Should be not full and empty
        
        // Test 5: Try to read when empty (should be blocked)
        $display("=== Test 5: Read When Empty (Should Fail) ===");
        read_fifo_sync();
        check_flags(0, 1); // Should still be not full and empty
        
        // Test 6: Fill and empty cycle to verify consistency
        $display("=== Test 6: Fill/Empty Cycle Verification ===");
        for (int cycle = 0; cycle < 2; cycle++) begin
            $display("--- Cycle %d ---", cycle);
            
            // Fill completely
            for (int i = 0; i < FIFO_DEPTH; i++) begin
                write_fifo_sync(8'hA0 + i);
            end
            check_flags(1, 0); // Verify full
            
            // Empty completely
            for (int i = 0; i < FIFO_DEPTH; i++) begin
                read_fifo_sync();
            end
            check_flags(0, 1); // Verify empty
        end
        
        $display("=== Testbench Complete ===");
        #50 $finish;
    end
    
    // Monitor for flag changes
    always @(posedge clk) begin
        if (rst_n && (wr_en || rd_en)) begin
            $display("Time=%t: Operation - WR=%b RD=%b Count=%d Full=%b Empty=%b", 
                     $time, wr_en, rd_en, count, full, empty);
        end
    end
    
endmodule

module tb_sram_controller();
    logic        clk;
    logic        rst_n;
    logic        read_req;
    logic        write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic        ready;
    
    // SRAM interface
    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce_n;
    logic        sram_oe_n;
    logic        sram_we_n;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate the SRAM controller
    sram_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .read_req(read_req),
        .write_req(write_req),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .ready(ready),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .sram_ce_n(sram_ce_n),
        .sram_oe_n(sram_oe_n),
        .sram_we_n(sram_we_n)
    );
    
    // Asynchronous SRAM model
    sram_model sram (
        .clk(clk),
        .ce_n(sram_ce_n),
        .oe_n(sram_oe_n),
        .we_n(sram_we_n),
        .addr(sram_addr),
        .data(sram_data)
    );
    
    // Helper task for writing to SRAM (synchronous)
    task write_sram;
        input [14:0] addr;
        input [15:0] data;
        begin
            @(posedge clk);
            write_req <= 1;
            address <= addr;
            write_data <= data;
            
            // Wait for ready signal
            do begin
                @(posedge clk);
            end while (!ready);
            
            write_req <= 0;
            address <= 0;
            write_data <= 0;
        end
    endtask
    
    // Helper task for reading from SRAM (synchronous)
    task read_sram;
        input [14:0] addr;
        begin
            @(posedge clk);
            read_req <= 1;
            address <= addr;
            
            // Wait for ready signal
            do begin
                @(posedge clk);
            end while (!ready);
            
            read_req <= 0;
            address <= 0;
        end
    endtask
    
    // Synchronous test sequence
    initial begin
        // Initialize VCD dump
        $dumpfile("6.vcd");
        $dumpvars(0, tb_sram_controller);
        
        // Initialize signals
        clk = 0;
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;
        
        // Test 1: Reset
        repeat(4) @(posedge clk);
        rst_n <= 1;
        @(posedge clk);
        $display("Time=%t: Reset complete", $time);
        
        // Test 2: Write operation
        write_sram(15'h1234, 16'hABCD);
        $display("Time=%t: Write complete - Addr=0x%h, Data=0x%h", $time, 15'h1234, 16'hABCD);
        
        // Test 3: Read operation
        read_sram(15'h1234);
        $display("Time=%t: Read complete - Addr=0x%h, Data=0x%h", $time, 15'h1234, read_data);
        
        // Test 4: Write to multiple addresses
        write_sram(15'h0000, 16'h1111);
        write_sram(15'h0001, 16'h2222);
        write_sram(15'h0002, 16'h3333);
        $display("Time=%t: Multiple writes complete", $time);
        
        // Test 5: Read from multiple addresses
        read_sram(15'h0000);
        $display("Time=%t: Read Addr=0x%h, Data=0x%h", $time, 15'h0000, read_data);
        read_sram(15'h0001);
        $display("Time=%t: Read Addr=0x%h, Data=0x%h", $time, 15'h0001, read_data);
        read_sram(15'h0002);
        $display("Time=%t: Read Addr=0x%h, Data=0x%h", $time, 15'h0002, read_data);
        
        // Test 6: Back-to-back operations (synchronous)
        @(posedge clk);
        write_req <= 1;
        read_req <= 1;  // This should be handled according to priority
        address <= 15'h5555;
        write_data <= 16'hAAAA;
        
        // Wait for operation to complete
        do begin
            @(posedge clk);
        end while (!ready);
        
        write_req <= 0;
        read_req <= 0;
        address <= 0;
        write_data <= 0;
        $display("Time=%t: Back-to-back operation complete", $time);
        
        // Test 7: Additional edge case - rapid consecutive operations
        write_sram(15'h7FFF, 16'hDEAD);
        read_sram(15'h7FFF);
        $display("Time=%t: Edge case test complete - Data=0x%h", $time, read_data);
        
        // Finish simulation
        repeat(10) @(posedge clk);
        $finish;
    end
    
    // Monitor to display important events (synchronous)
    always @(posedge clk) begin
        if (rst_n && (read_req || write_req || ready)) begin
            $display("Time=%t: State=%s, Ready=%b, Addr=0x%h, WriteData=0x%h, ReadData=0x%h", 
                     $time, dut.curr_state.name(), ready, address, write_data, read_data);
        end
    end
endmodule

// Asynchronous SRAM model
module sram_model (
    input  logic        clk,
    input  logic        ce_n,
    input  logic        oe_n,
    input  logic        we_n,
    input  logic [14:0] addr,
    inout  wire  [15:0] data
);
    
    // Memory array
    reg [15:0] memory [0:32767];
    
    // Internal data register
    reg [15:0] data_out;
    
    // Tri-state buffer control
    assign data = (!ce_n && !oe_n && we_n) ? data_out : 16'bz;
    
    // Write operation
    always @(posedge clk) begin
        if (!ce_n && !we_n) begin
            memory[addr] <= data;
            $display("SRAM Write: Addr=0x%h, Data=0x%h", addr, data);
        end
    end
    
    // Read operation
    always @(posedge clk) begin
        if (!ce_n && we_n) begin
            data_out <= memory[addr];
            $display("SRAM Read: Addr=0x%h, Data=0x%h", addr, memory[addr]);
        end
    end
    
    // Initialize memory with random values
    initial begin
        for (int i = 0; i < 32768; i++) begin
            memory[i] = $random;
        end
    end
endmodule

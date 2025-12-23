module sram_controller_tb ();
    // Testbench parameters
    localparam CLK_PERIOD = 10; // 100 MHz clock
    
    // DUT signals
    logic        clk;
    logic        rst_n;
    logic        read_req;
    logic        write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic        ready;
    
    // SRAM interface signals
    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce_n;
    logic        sram_oe_n;
    logic        sram_we_n;
    
    // SRAM model
    logic [15:0] sram_memory [0:32767]; // 32Kx16 SRAM
    
    // Bidirectional data bus
    logic [15:0] sram_data_out;
    logic        sram_data_en;
    
    assign sram_data = sram_data_en ? sram_data_out : 16'bz;
    
    // Instantiate DUT
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
    
    // SRAM behavior model
    always_comb begin
        if (!sram_ce_n && !sram_oe_n && sram_we_n) begin
            // Read operation
            sram_data_out <= sram_memory[sram_addr];
            sram_data_en <= 1'b1;
        end else if (!sram_ce_n && !sram_we_n) begin
            // Write operation
            sram_memory[sram_addr] <= sram_data;
            sram_data_en <= 1'b0;
        end else begin
            sram_data_en <= 1'b0;
        end
    end
    
    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst_n = 1'b0;
        read_req = 1'b0;
        write_req = 1'b0;
        address = 15'b0;
        write_data = 16'b0;
        
        // Reset the system
        #(CLK_PERIOD);
        rst_n = 1'b1;
        #(CLK_PERIOD);
        
        // Test 1: Write operation
        $display("Test 1: Writing to SRAM");
        write_req = 1'b1;
        address = 15'h0;
        write_data = 16'hABCD;
        #(CLK_PERIOD);
        write_req = 1'b0;
        
        // Wait for ready
        wait(ready);
        #(CLK_PERIOD);
        
        // Test 2: Read operation
        $display("Test 2: Reading from SRAM");
        read_req = 1'b1;
        address = 15'h0;
        #(CLK_PERIOD);
        read_req = 1'b0;
        
        #15;
        if (read_data === 16'hABCD) 
            $display("SUCCESS: Read correct data: %h", read_data);
        else
            $display("ERROR: Expected %h, got %h", 16'hABCD, read_data);
        
        
        
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time: %0t, State: %s, Ready: %b, Addr: %h, Data: %h", 
                 $time, dut.state.name, ready, address, read_data);
    end
    
endmodule
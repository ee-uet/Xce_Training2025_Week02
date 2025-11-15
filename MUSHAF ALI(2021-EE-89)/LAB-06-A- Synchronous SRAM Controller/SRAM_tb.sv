module sram_controller_tb;

    // Testbench signals
    logic        clk;
    logic        rst;
    logic        read_req;
    logic        write_req;
    logic [15:0] data_cpu;
    logic [14:0] addr_cpu;
    logic [15:0] read_data;
    logic        ready;
    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        oe;
    logic        dq_oe;
    logic        we;
    logic        ce;

    // Instantiate DUT (Device Under Test)
    sram_controller dut (
        .clk(clk),
        .rst(rst),
        .read_req(read_req),
        .write_req(write_req),
        .data_cpu(data_cpu),
        .addr_cpu(addr_cpu),
        .read_data(read_data),
        .ready(ready),
        .sram_addr(sram_addr),
        .sram_data(sram_data),
        .oe(oe),
        .we(we),
        .dq_oe(dq_oe),
        .ce(ce)
    );

    // Simple SRAM model
    logic [15:0] mem [0:32767];  // 32K x 16-bit memory
    logic [15:0] sram_data_out;
    assign sram_data = (!ce && !oe && we) ? sram_data_out : 16'hzzzz;

    // SRAM behavior
    always @(negedge clk) begin
        if (!ce && !we) begin  // Write on falling edge if CE and WE low
            mem[sram_addr] <= sram_data;
        end
        if (!ce && !oe) begin  // Read data available after delay
            sram_data_out <= mem[sram_addr];
        end
    end

    // Clock generation (100 MHz, 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        read_req = 0;
        write_req = 0;
        data_cpu = 0;
        addr_cpu = 0;

        // Initialize SRAM memory
        for (int i = 0; i < 32768; i++) mem[i] = 0;

        // Reset
        $display("Starting reset test...");
        #20 rst = 0;
        #10;
        assert(ready == 1) else $error("Ready not high after reset");
        assert(ce == 1 && oe == 1 && we == 1 && dq_oe == 0) else $error("Control signals not reset");

        // Test 1: Single write
        $display("Test 1: Single write to address 0x1000");
        @(posedge clk);
        addr_cpu = 15'h1000;
        data_cpu = 16'hBEEF;
        write_req = 1;
        @(posedge clk);
        write_req = 0;
        wait(ready == 1);
        #10;
        assert(mem[15'h1000] == 16'hBEEF) else $error("Write failed: mem[0x1000] = %h, expected BEEF", mem[15'h1000]);

        // Test 2: Single read
        $display("Test 2: Single read from address 0x1000");
        @(posedge clk);
        addr_cpu = 15'h1000;
        read_req = 1;
        @(posedge clk);
        read_req = 0;
        wait(ready == 1);
        #10;
        assert(read_data == 16'hBEEF) else $error("Read failed: read_data = %h, expected BEEF", read_data);

        // Test 3: Back-to-back write then read
        $display("Test 3: Back-to-back write then read");
        @(posedge clk);
        addr_cpu = 15'h2000;
        data_cpu = 16'hDEAD;
        write_req = 1;
        @(posedge clk);
        write_req = 0;
        wait(ready == 1);
        @(posedge clk);
        addr_cpu = 15'h2000;
        read_req = 1;
        @(posedge clk);
        read_req = 0;
        wait(ready == 1);
        #10;
        assert(read_data == 16'hDEAD) else $error("Back-to-back failed: read_data = %h, expected DEAD", read_data);

        // Test 4: Simultaneous read and write (undefined behavior, just observe)
        $display("Test 4: Simultaneous read and write to address 0x3000");
        @(posedge clk);
        addr_cpu = 15'h3000;
        data_cpu = 16'hCAFE;
        read_req = 1;
        write_req = 1;
        @(posedge clk);
        read_req = 0;
        write_req = 0;
        wait(ready == 1);
        #10;

        // Finish
        $display("Testbench completed");
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t rst=%b state=%0d read_req=%b write_req=%b ce=%b oe=%b we=%b dq_oe=%b addr=%h sram_data=%h read_data=%h ready=%b",
                 $time, rst, dut.current_state, read_req, write_req, ce, oe, we, dq_oe, sram_addr, sram_data, read_data, ready);
    end

endmodule
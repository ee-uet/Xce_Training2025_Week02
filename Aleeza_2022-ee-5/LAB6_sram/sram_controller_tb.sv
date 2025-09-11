module sram_controller_tb;

    // Testbench signals
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

    // Internal SRAM storage (Behavioral model)
    logic [15:0] sram_mem [0:32767];  // 32K x 16
    logic [15:0] sram_dq_reg;
    logic        sram_drive;

    // Bidirectional bus connection
    assign sram_data = (sram_drive) ? sram_dq_reg : 16'bz;

    // SRAM model behavior
    always_ff @(posedge clk) begin
        if (!sram_ce_n) begin
            if (!sram_we_n) begin
                // Write operation
                sram_mem[sram_addr] <= sram_data;
            end
            else if (!sram_oe_n) begin
                // Read operation
                sram_dq_reg <= sram_mem[sram_addr];
            end
        end
    end

    // Drive control for read
    always_comb begin
        sram_drive = (!sram_ce_n && !sram_oe_n && sram_we_n);
    end

    // DUT instantiation
    sram_controller dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .read_req   (read_req),
        .write_req  (write_req),
        .address    (address),
        .write_data (write_data),
        .read_data  (read_data),
        .ready      (ready),
        .sram_addr  (sram_addr),
        .sram_data  (sram_data),
        .sram_ce_n  (sram_ce_n),
        .sram_oe_n  (sram_oe_n),
        .sram_we_n  (sram_we_n)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz
    end

    // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;
        #20;
        rst_n = 1;

        // --- Test 1: Write data to SRAM ---
        @(posedge clk);
        address    = 15'h0005;
        write_data = 16'hABCD;
        write_req  = 1;
        @(posedge clk);
        write_req  = 0;
        #10;
        $display("Write: Addr=%h Data=%h", address, write_data);

        // --- Test 2: Read back the data ---
        @(posedge clk);
        address   = 15'h0005;
        read_req  = 1;
        @(posedge clk);
        read_req  = 0;
        #10;
        $display("Read : Addr=%h Data=%h", address, read_data);

        // --- Test 3: Another write and read ---
        @(posedge clk);
        address    = 15'h000A;
        write_data = 16'h1234;
        write_req  = 1;
        @(posedge clk);
        write_req  = 0;
        #10;
        $display("Write: Addr=%h Data=%h", address, write_data);

        @(posedge clk);
        address   = 15'h000A;
        read_req  = 1;
        @(posedge clk);
        read_req  = 0;
        #10;
        $display("Read : Addr=%h Data=%h", address, read_data);

        // End simulation
        #50;
        $finish;
    end

endmodule


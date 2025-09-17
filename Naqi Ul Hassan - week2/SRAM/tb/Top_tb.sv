module Top_tb;

    // tb signals
    logic clk;
    logic rst_n;
    logic read_req;
    logic write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    logic [14:0] sram_addr;
    wire  [15:0] sram_data;
    logic        sram_ce;
    logic        sram_oe;
    logic        sram_we;

    // simple sram model
    logic [15:0] sram_mem [0:(1<<15)-1];
    logic [15:0] sram_out;
    assign sram_data = (!sram_ce && !sram_oe && sram_we) ? sram_out : 16'bz;
    always_ff @(posedge clk) begin
        if (!sram_ce && !sram_we) // write
            sram_mem[sram_addr] <= sram_data;
        if (!sram_ce && !sram_oe) // read
            sram_out <= sram_mem[sram_addr];
    end

    // dut
    Top dut (
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
        .sram_ce(sram_ce),
        .sram_oe(sram_oe),
        .sram_we(sram_we)
    );

    // clk
    initial clk = 0;
    always #5 clk = ~clk;

    // seq
    initial begin
        // reset
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;
        #12 rst_n = 1;

        // write 0xABCD @ 0x0010
        @(posedge clk);
        address    = 15'h0010;
        write_data = 16'hABCD;
        write_req  = 1;
        @(posedge clk);
        write_req  = 0;

        // wait a bit
        repeat (2) @(posedge clk);

        // read @ 0x0010
        address   = 15'h0010;
        read_req  = 1;
        @(posedge clk);
        read_req  = 0;

        // wait to capture read
        repeat (2) @(posedge clk);

        // check
        if (read_data == 16'hABCD)
            $display("READ OK: %h", read_data);
        else
            $error("READ FAIL: got %h", read_data);

        $finish;
    end

endmodule

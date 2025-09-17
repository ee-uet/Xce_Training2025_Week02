module tb_axi4_lite;
    logic        clk;
    logic        rst_n;
    logic        write_req;
    logic [31:0] write_address;
    logic [31:0] write_data;
    logic [3:0]  write_strb;
    logic        write_done;
    logic [1:0]  write_response;
    logic        read_req;
    logic [31:0] read_address;
    logic        read_done;
    logic [31:0] read_data;
    logic [1:0]  read_response;

    // Instantiate DUT
    axi4_lite_top UUT (
        .clk           (clk),
        .rst_n         (rst_n),
        .write_req     (write_req),
        .write_address (write_address),
        .write_data    (write_data),
        .write_strb    (write_strb),
        .write_done    (write_done),
        .write_response(write_response),
        .read_req      (read_req),
        .read_address  (read_address),
        .read_done     (read_done),
        .read_data     (read_data),
        .read_response (read_response)
    );

    // Clock generation - 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize
        rst_n          = 0;
        write_req      = 0;
        write_address  = 0;
        write_data     = 0;
        write_strb     = 0;
        read_req       = 0;
        read_address   = 0;

        #50 rst_n = 1;
        #50;

        $display("=== AXI4-Lite Test Start ===");

        // -------- Write to register 0 (control) --------
        write_address = 32'h0000_000C;
        write_data    = 32'hDEAD_BEEF;
        write_strb    = 4'hF;
        write_req     = 1;
        #10 write_req = 0;
        wait(write_done);
        $display("Write reg0: data=0x%08h, resp=%0d", write_data, write_response);
        #50;

        // -------- Read from register 0 --------
        read_address = 32'h0000_000C;
        read_req     = 1;
        #10 read_req = 0;
        wait(read_done);
        $display("Read reg0: data=0x%08h, resp=%0d", read_data, read_response);
        #100;

        $finish;
    end

endmodule

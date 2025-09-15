module top_module_tb;

    logic        clk;
    logic        rst_n;
    logic        write_req;
    logic [31:0] write_addr;
    logic [31:0] write_data;
    logic [3:0]  write_strb;
    logic        write_done;
    logic [1:0]  write_resp;

    logic        read_req;
    logic [31:0] read_addr;
    logic        read_done;
    logic [31:0] read_data;
    logic [1:0]  read_resp;

    // Instantiate DUT
    axi4_lite_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .write_req(write_req),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_strb(write_strb),
        .write_done(write_done),
        .write_resp(write_resp),
        .read_req(read_req),
        .read_addr(read_addr),
        .read_done(read_done),
        .read_data(read_data),
        .read_resp(read_resp)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        rst_n = 0;
        write_req = 0;
        write_addr = 32'h04;
        write_data = 32'hA5A5A5A5;
        write_strb = 4'b1111;
        read_req = 0;
        read_addr = 32'h00;

        #3
        rst_n = 1;
        @(posedge clk);
        #2
        write_req = 1;
        @(posedge clk);
        #1
        write_req = 0;
        @(posedge clk);
        wait(write_done);
        #2
        read_req = 1;
        read_addr = 32'h04;
        @(posedge clk);
        #2
        read_req = 0;
        repeat (10) @(posedge clk);
       
        $finish;
    end

endmodule
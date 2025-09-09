module tb_axi4_lite;
    logic        aclk;
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
    axi4_lite_top UUT (
        .aclk(aclk),
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

    // Clock generation - 100MHz
    initial aclk = 0;
    always #5 aclk = ~aclk;

    initial begin
        // Initialize
        rst_n = 0;
        write_req = 0;
        write_addr = 0;
        write_data = 0;
        write_strb = 0;
        read_req = 0;
        read_addr = 0;
        
        #50 rst_n = 1;
        #100;
        
        // Write to address 0x00
        write_addr = 32'h00000000;
        write_data = 32'h12345678;
        write_strb = 4'hF;
        write_req = 1;
        #10 write_req = 0;
        
        // Wait for write complete
        wait(write_done);
        #50;
        
        // Read from address 0x00
        read_addr = 32'h00000000;
        read_req = 1;
        #10 read_req = 0;
        
        // Wait for read complete
        wait(read_done);
        #50;
        
        // Write to address 0x04
        write_addr = 32'h00000004;
        write_data = 32'hAABBCCDD;
        write_strb = 4'hF;
        write_req = 1;
        #10 write_req = 0;
        
        wait(write_done);
        #50;
        
        // Read from address 0x04
        read_addr = 32'h00000004;
        read_req = 1;
        #10 read_req = 0;
        
        wait(read_done);
        #50;
        
        $finish;
    end


endmodule
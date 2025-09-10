import pkg::*;
module axi4_lite_slave_tb #(TESTS=100) ();
    logic clk, rst_n;
    logic [31:0] addr, data;
    logic [1:0] response;
    axi4_lite_if IF(.*);
    axi4_lite_slave Slave(.axi_if(IF.slave), .*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
        @(posedge clk);
        for (int i = 0; i < TESTS; i++) begin
            addr = $urandom_range(0, 20);
            data = $random;
            write_task(addr, data, response);
            $display("write operation=addr:%h,data:%d,response:%d", addr, data, response);
            @(posedge clk);
            addr = $urandom_range(0, 20);
            read_task(addr, data, response); 
            $display("read operation=addr:%h,data:%d,response:%d", addr, data, response);
            @(posedge clk);
        end
        #10 $finish; 
    end

    task automatic write_task(input logic [31:0] addr, input logic [31:0] data, output logic [1:0] response);
        IF.master.awaddr = addr;
        IF.master.awvalid = 1;
        IF.master.wvalid = 0;
        IF.master.wstrb  = $urandom_range(0,15);
        IF.master.bready = 0;
        while (!IF.master.awready) @(posedge clk);
        IF.master.awvalid = 0;
        @(posedge clk);
        IF.master.wdata = data;
        IF.master.wvalid = 1;
        while (!IF.master.wready) @(posedge clk);
        @(posedge clk);
        IF.master.wvalid = 0;
        while (!IF.master.bvalid) @(posedge clk);
        @(posedge clk);
        IF.master.bready = 1;
        response = IF.master.bresp;
        @(posedge clk);
        IF.master.bready = 0; 
    endtask

    task automatic read_task(input logic [31:0] addr, output logic [31:0] data, output logic [1:0] response);
        IF.master.araddr = addr;
        IF.master.arvalid = 1;
        IF.master.rready = 1'b0;
        while (!IF.master.arready) @(posedge clk);
        IF.master.arvalid = 0;
        while (!IF.master.rvalid) @(posedge clk); 
        data = IF.master.rdata;
        IF.master.rready = 1'b1;
        response = IF.master.rresp;
        @(posedge clk);
        IF.master.rready = 0; 
    endtask
endmodule
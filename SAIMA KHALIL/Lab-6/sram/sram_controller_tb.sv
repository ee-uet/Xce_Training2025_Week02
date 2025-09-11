module sram_controller_tb;
    logic clk;
    logic rst_n;
    logic read_req;
    logic write_req;
    logic [14:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic ready;

    // SRAM interface
    logic [14:0] sram_addr;
    tri   [15:0] sram_data;     
    logic        sram_ce_n;
    logic        sram_oe_n; 
    logic        sram_we_n;

    // Internal memory  for SRAM (16-bit wide, 32K deep)
    logic [15:0] mem [0:(1<<15)-1];
    logic [15:0] sram_data_drv;  // data to be provided to the bus

    //slave is driving here,the bus
    assign sram_data =  ((!sram_oe_n && !sram_ce_n) ? sram_data_drv : 16'bz);

    // writing data into dummy slave :D
    always_ff @(posedge clk) begin
        if (!sram_ce_n && !sram_we_n) begin
            mem[sram_addr] <= sram_data;   
        end
    end

    always_comb begin
        if (!sram_ce_n && !sram_oe_n) begin
            sram_data_drv = mem[sram_addr]; // Read
        end else begin
            sram_data_drv = 16'bz;
        end
    end
 
    sram_controller dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
       
        rst_n = 0;
        read_req = 0;
        write_req = 0;
        address = 0;
        write_data = 0;

      
        #20;
        rst_n = 1;
        @(posedge clk); @(posedge clk);

        address = 15'd5;
        write_data = 16'h1122;
        write_req = 1;

        @(posedge clk);
        write_req  = 0;

        @(posedge clk);
        read_req = 1;
        address = 15'd5;
        $display("Read Data = %h", read_data);

        
        @(posedge clk);
        read_req = 0;

        $finish;
    end

endmodule

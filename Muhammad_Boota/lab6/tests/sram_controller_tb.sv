module sram_controller_tb #(TESTS=100)(
);
    logic        clk;         
    logic        rst_n;       
    logic        read_req;    
    logic        write_req;   
    logic [14:0] address;     
    logic [15:0] write_data;  
    logic [15:0] read_data;  
    logic        ready;       
    // interface
    logic [14:0] sram_addr;  
    wire [15:0]  sram_data;  
    logic        sram_ce_n;  
    logic        sram_oe_n;  
    logic        sram_we_n;

sram_controller Sram_Controller (
    .*
);

initial begin
    clk=0;
    forever begin
        #5 clk =~clk;
    end
end

initial begin
    rst_n=0;    
    read_req=0; 
    write_req=0;
    address=0;  
    write_data=0;    
    #20;
    rst_n=1;
    @(posedge (clk));
    for (int i =0 ;i<TESTS ;i++ ) begin
        read_req=$urandom_range(0,1);
        write_req=$urandom_range(0,1);
        address=$urandom_range(0,50);
        write_data=$urandom_range(0,200);
        $display("read_req:%d,write_req:%d,address:%h,write_data:%d,sram_data%d",read_req,write_req,address,write_data,sram_data);
        @(posedge(clk));
        while(!ready)begin
            $display("ready:%d,sram_addr:%h,sram_data:%d,sram_ce_n:%d,sram_oe_n:%d,sram_we_n:%d",ready,sram_addr,sram_data,sram_ce_n,sram_oe_n,sram_we_n);
            @(posedge (clk));
        end
        $display("ready:%d,sram_addr:%h,sram_data:%d,sram_ce_n:%d,sram_oe_n:%d,sram_we_n:%d",ready,sram_addr,sram_data,sram_ce_n,sram_oe_n,sram_we_n);
        @(posedge (clk));
        read_req=~read_req;
        write_req=~write_req;
        $display("read_req:%d,write_req:%d,address:%h,write_data:%d,sram_data%d",read_req,write_req,address,write_data,sram_data);
        @(posedge(clk));
        while(!ready)begin
            $display("ready:%d,sram_addr:%h,sram_data:%d,sram_ce_n:%d,sram_oe_n:%d,sram_we_n:%d",ready,sram_addr,sram_data,sram_ce_n,sram_oe_n,sram_we_n);
            @(posedge (clk));
        end
        $display("ready:%d,sram_addr:%h,sram_data:%d,sram_ce_n:%d,sram_oe_n:%d,sram_we_n:%d",ready,sram_addr,sram_data,sram_ce_n,sram_oe_n,sram_we_n);
        @(posedge (clk));
    end
    $stop;
end
endmodule

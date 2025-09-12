import pkg::*;
module spi_master_tb #( TESTS=1000,
parameter int NUM_SLAVES = 4,
parameter int DATA_WIDTH = 8
)();
logic clk;
logic rst_n;
logic [DATA_WIDTH-1:0] tx_data;
logic [$clog2(NUM_SLAVES)-1:0] slave_sel;
logic start_transfer;
logic cpol;
logic cpha;
logic [15:0] clk_div;
logic [DATA_WIDTH-1:0] rx_data;
logic transfer_done;
logic busy;
logic spi_clk;
logic spi_mosi;
logic spi_miso;
logic [NUM_SLAVES-1:0] spi_cs_n;

spi_master spi_master(
    .*
);
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end

initial begin
    rst_n=0;
    #20
    rst_n=1;
    @(posedge(clk));
    for (int i =0 ;i<TESTS ;i++ ) begin
        slave_sel=$urandom_range(0,3);
        cpha=$urandom_range(0,1);
        cpol=$urandom_range(0,1);
        clk_div=$urandom_range(4,8);
        @(posedge(clk));
        fork
            miso_test(i);
            mosi_test(i);
        join
        @(posedge(clk));
        end
        $finish;
    end
    
task automatic miso_test(input int test);
        logic [DATA_WIDTH-1:0] data;
        data=$urandom_range(0,256);
        @(posedge(clk));
        start_transfer=1;
        @(posedge(clk));
        start_transfer=0;
        case ({cpol,cpha})
            2'b00:begin
                for (int i = 8;i>0 ;i-- ) begin
                    @(posedge (spi_clk));
                    spi_miso=data[i-1];
                end
            end
            2'b10:begin
                for (int i = 8;i>0 ;i-- ) begin
                    @(negedge (spi_clk));
                    spi_miso=data[i-1];
                end
            end
            2'b01:begin
                for (int i = 8;i>0 ;i-- ) begin
                    spi_miso=data[i-1];
                    @(negedge (spi_clk));
                end
            end
            2'b11:begin
                for (int i = 8;i>0 ;i-- ) begin
                    spi_miso=data[i-1];
                    @(posedge (spi_clk));
                end
            end
            default: begin
                $error("Invalid CPOL/CPHA combination");
                $stop;
            end
        endcase
        @(posedge(clk));
        while(busy)
            @(posedge clk);
        @(posedge(clk));
        if (data !== rx_data) begin
            $error("MISO data mismatch: expected %0h, got %0h",data,rx_data);
            $stop;
        end else begin
            $display("Test:%d passed,MISO data match: expected %0h, got %0h",test,data,rx_data);
        end
endtask //automatic


task automatic mosi_test(input int test);
        logic [DATA_WIDTH-1:0] data,received_data;
        data=$urandom_range(0,256);
        @(posedge(clk));
        tx_data=data;
        start_transfer=1;
        @(posedge(clk));
        start_transfer=0;
        case ({cpol,cpha})
            2'b00:begin
                for (int i = 8;i>0 ;i-- ) begin
                @(posedge (spi_clk));
                #1;
                received_data[i-1]=spi_mosi;
        end
            end
            2'b10:begin
                for (int i = 8;i>0 ;i-- ) begin
                @(negedge (spi_clk));
                #1;
                received_data[i-1]=spi_mosi;
        end
            end
            2'b01:begin
                for (int i = 8;i>0 ;i-- ) begin
                @(posedge (spi_clk));
                received_data[i-1]=spi_mosi;
        end
            end
            2'b11:begin
                for (int i = 8;i>0 ;i-- ) begin
                    @(negedge (spi_clk));
                    received_data[i-1]=spi_mosi;
                end
            end
            default: begin
                $error("Invalid CPOL/CPHA combination");
                $stop;
            end
        endcase
        @(posedge(clk));
        while(busy)
            @(posedge clk);
        @(posedge(clk));
        if (data !== received_data) begin
            $error("MOSI data mismatch: expected %0h, got %0h",data,received_data);
            $stop;
        end else begin
            $display("Test:%d passed,MOSI data match: expected %0h, got %0h",test,data,received_data);
        end
endtask //automatic
endmodule
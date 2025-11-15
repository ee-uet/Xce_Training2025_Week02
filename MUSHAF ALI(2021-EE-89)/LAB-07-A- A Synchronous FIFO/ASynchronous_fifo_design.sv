module Async_fifo #(
    parameter DEPTH=32,
    parameter DATA_WIDTH=8
)
(
    input logic write_enable,
    input logic read_enable,
    input logic clk_wr,
    input logic clk_rd,
    input logic rst,
    input logic  [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic fifo_empty,fifo_full,fifo_almost_full,fifo_almost_empty
);
//internal signals
///////////////////////// LET SAY (DEPTH = 8 → ADDR_WIDTH = 3, PTR_WIDTH = 4)...........thats why 
localparam integer ADDR_WIDTH=$clog2(DEPTH);
localparam integer PTR_WIDTH=ADDR_WIDTH+1; // this extra bit necessory for distinguish between full and empty ane domain w.r.t other domain.
localparam integer AF_THRESHOLD = DEPTH-2; // almost full when <= 2 slots left
localparam integer AE_THRESHOLD = 1;       // almost empty when <= 1 slot left
//fifo memory
logic [DATA_WIDTH-1:0] fifo_memory [0:DEPTH-1];
// write and read pointers (BINARY)
logic [PTR_WIDTH-1:0] write_pointer_bin; //but i will use pointers for detection of fifo full and empty cuz extra bit is included in pointers not addressees addresses are jut the lower 3 bits the MSB is the actual bit which helps me to detect the flag 
logic [PTR_WIDTH-1:0] read_pointer_bin;
//ACTUAL MEM INDEX
logic [ADDR_WIDTH-1:0] write_addr;
logic [ADDR_WIDTH-1:0] read_addr;
assign write_addr = write_pointer_bin[ADDR_WIDTH-1:0];
assign read_addr = read_pointer_bin[ADDR_WIDTH-1:0];
// write and read pointers (GRAY CODED)
logic [PTR_WIDTH-1:0] write_pointer_gray;
logic [PTR_WIDTH-1:0] read_pointer_gray;














///////////////////////////////// write ponter domain running on clk_wr \\\\\\\\\\\\\\\\\\\\\\


//function to convert gray to back in binary

function automatic [PTR_WIDTH-1:0] gray2bin(input [PTR_WIDTH-1:0] g);
    integer i;
    begin
        gray2bin[PTR_WIDTH-1] = g[PTR_WIDTH-1]; // MSB same
        for (i = PTR_WIDTH-2; i >= 0; i=i-1)
            gray2bin[i] = gray2bin[i+1] ^ g[i]; 
    end
endfunction









//flip flop declarations used for Synch rst.
logic ff4,ff5,ff6;
logic synchronized_rst_wr_domain;

//rst is synchronized and safely used after this..........
always_ff @(posedge clk_wr or posedge rst) begin
    if(rst) begin
        ff4<=1'b1;
        ff5<=1'b1;
        ff6<=1'b1;
    end
    else begin
        ff4<=1'b0;
        ff5<=ff4;
        ff6<=ff5;
    end
end
assign synchronized_rst_wr_domain = ff6;



//now here i am going to synchronize the read_pointer_gray for safe use in fifo flag checking
logic [PTR_WIDTH-1:0] ff10,ff11,ff12;
logic [PTR_WIDTH-1:0] read_pointer_gray_synchronized;
//read_pointer_gray is synchronized and safely used after this..........

always_ff @(posedge clk_wr or posedge rst) begin
    if(rst) begin
        ff10<=1'b0;
        ff11<=1'b0;
        ff12<=1'b0;
    end
    else begin
        ff10<=read_pointer_gray;
        ff11<=ff10;
        ff12<=ff11;
    end
end
assign read_pointer_gray_synchronized = ff12;


//now rst is safe and can be used..................
logic [PTR_WIDTH-1:0] next_write_bin;
logic [PTR_WIDTH-1:0] next_write_gray;
logic [PTR_WIDTH-1:0] fifo_count_wr;
always_ff @ (posedge clk_wr) begin
    if(synchronized_rst_wr_domain) begin
        fifo_full<=0;
        fifo_almost_full<=0;
        write_pointer_bin<=0;
        write_pointer_gray<=0;
        fifo_count_wr<=0;
        for(int i=0;i<DEPTH;i++) fifo_memory[i]<=0;
    end
    else begin
        if(write_enable && !fifo_full) begin
            fifo_memory[write_addr] <= data_in;
            //next state calculation
            next_write_bin = (write_pointer_bin +1);
            next_write_gray = (next_write_bin ^ (next_write_bin>>1));

            ///after calculation update the registers
            write_pointer_bin <= next_write_bin;
            write_pointer_gray <=next_write_gray;
        end


        //flag generation
        fifo_full <= (write_pointer_gray == {~read_pointer_gray_synchronized[PTR_WIDTH-1:PTR_WIDTH-2],read_pointer_gray_synchronized[PTR_WIDTH-3:0]});
        fifo_count_wr <= (write_pointer_bin - gray2bin(read_pointer_gray_synchronized));   // (gray2bin(read_pointer_gray_synchronized) this function will conver the bgray to bin back for arithmatic cuz arithmatic is hard in gray but in bin its easy
        fifo_almost_full <= (fifo_count_wr >= AF_THRESHOLD);
    end
end









///////////////////////////////// read ponter domain running on clk_rd \\\\\\\\\\\\\\\\\\\\\\

//flip flop declarations used for Synch rst.
logic  ff1,ff2,ff3;
logic synchronized_rst_rd_domain;
//rst is synchronized and safely used after this..........
always_ff @(posedge clk_rd or posedge rst) begin
    if(rst) begin
        ff1<=1'b1;
        ff2<=1'b1;
        ff3<=1'b1;
    end
    else begin
        ff1<=1'b0;
        ff2<=ff1;
        ff3<=ff2;
    end
end
assign synchronized_rst_rd_domain = ff3;



//now here i am going to synchronize the write_pointer_gray for safe use in fifo flag checking
logic [PTR_WIDTH-1:0] ff7,ff8,ff9;
logic [PTR_WIDTH-1:0] write_pointer_gray_synchronized;
//read_pointer_gray is synchronized and safely used after this..........

always_ff @(posedge clk_rd or posedge rst) begin
    if(rst) begin
        ff7<=1'b0;
        ff8<=1'b0;
        ff9<=1'b0;
    end
    else begin
        ff7<=write_pointer_gray;
        ff8<=ff7;
        ff9<=ff8;
    end
end
assign write_pointer_gray_synchronized = ff9;


//now rst is safe and can be used..................
logic [PTR_WIDTH-1:0] next_read_bin;
logic [PTR_WIDTH-1:0] next_read_gray;
logic [PTR_WIDTH-1:0] fifo_count_rd;
always_ff @ (posedge clk_rd) begin
    if(synchronized_rst_rd_domain) begin   ///now this (synchronized_rst_rd_domain) is the sync rst. (can safely use)
        fifo_empty<=1;
        fifo_almost_empty<=1;
        read_pointer_bin<=0;
        read_pointer_gray<=0;
        data_out<=0;
    end
    else begin
        if(read_enable && !fifo_empty) begin
            data_out<= fifo_memory[read_addr];
            //current state calculation
            next_read_bin =(read_pointer_bin + 1);
            next_read_gray = (next_read_bin ^ (next_read_bin>>1));
            //updating registers with corect results
            read_pointer_bin <= next_read_bin;
            read_pointer_gray <=next_read_gray;
        end



        //flag generation
         fifo_empty <= (read_pointer_gray == write_pointer_gray_synchronized);
         fifo_count_rd <= (gray2bin(write_pointer_gray_synchronized)-read_pointer_bin);
         fifo_almost_empty <= (fifo_count_rd <= AE_THRESHOLD); 
    end
end

endmodule
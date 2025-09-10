module sync_fifo #(
    parameter  DEPTH=21,
    parameter  DATA_WIDTH=8
    ) 
    (
    input logic clk,rst,
    input logic write_enable,read_enable,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic fifo_empty,fifo_full,fifo_almost_full,fifo_almost_empty
);
//internal signals
localparam PTR_WIDTH = $clog2(DEPTH); 
localparam [PTR_WIDTH-1:0] AF_THRESHOLD=6;
localparam [PTR_WIDTH-1:0] AE_THRESHOLD=1;


// memory
logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

// write_pointer and read_pointer
logic [PTR_WIDTH-1:0] write_pointer;
logic [PTR_WIDTH-1:0] read_pointer;

// internal signal
logic [PTR_WIDTH-1:0] occupancy;


always_ff @(posedge clk) begin
    if(rst) begin
        data_out<=0;
        fifo_empty<=1;
        fifo_full<=0;
        write_pointer<=0;
        read_pointer<=0;
        occupancy<=0;
        fifo_almost_empty<=1;
        fifo_almost_full<=0;
    end
    else begin
        //write operation
         if(write_enable==1 && !fifo_full) begin
                memory[write_pointer]<=data_in;
                write_pointer <= ((write_pointer + 1) % DEPTH); // wrap around to 0 for DEPTH = power of 2 and for any arbitrary depth
        end

        //Read operation  
         if (read_enable==1 && !fifo_empty) begin
                data_out<=memory[read_pointer];
                read_pointer <= ((read_pointer + 1) % DEPTH);
            end

        //condition check
        fifo_full <= (((write_pointer +1) % DEPTH) == read_pointer);
        fifo_empty <= (write_pointer==read_pointer);
        occupancy <= ((write_pointer-read_pointer + DEPTH) % DEPTH);    //number of data elements currently in fifo
        fifo_almost_full <= ((DEPTH - occupancy)<=AF_THRESHOLD); //remaining space in fifo if less then the threshold of fifo to be assumed as almost full then its true
        fifo_almost_empty <= ((occupancy)<=AE_THRESHOLD); //if data elemnts in fifo are less then the predefined threshold if less then the fifo empty threshold then its true its
        end
    end
endmodule
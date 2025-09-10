module chache_controler (
    input  logic clk,rst,
    //////////////////////////////////  CPU INTERFASE \\\\\\\\\\\\\\\\\\\\\\\\\\
    input  logic read_req,write_req,flush_req,
    input  logic [31:0] address,
    input  logic [31:0] cpu_to_cache_data,
    output logic [31:0] cache_to_cpu_data,

////////////////////////////// MAIN MEM INTERFASE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    output  logic [127:0] cache_to_main_mem_data,
    input   logic [127:0] main_mem_to_cache_data,
    input   logic read_mem_ack,
    output  logic read_mem_req,
    output  logic write_mem_req,
    input   logic write_mem_ack,
    output logic [31:0] block_address
);

//internal signals
logic [19:0] tag_bits;
logic [7:0] index_bits;
logic [3:0] offset_bits;
//logic [11:0] tag_index_bits;

//decoding of address comming from cpu
//assign tag_index_bits = address [15:4];         // RAM IS 64kb
assign tag_bits       = address [31:12];
assign index_bits     = address [11:4];
assign offset_bits    = address [3:0]; 


//cache memory
logic [127:0] data_array [0:255]; //16 bytes data per block
logic [19:0] tag_array [0:255]; //20 bits tag per block
logic valid [0:255]; //1 bit valid bit per block
logic dirty [0:255]; //1 bit dirty bit per block

//cache status internal signals
logic cache_hit;
logic cache_miss;


//FLUSH counter 
logic [8:0] flush_index;
logic flush_done;

//request latched signals
logic latched_read_req;
logic latched_write_req;
logic latched_flush_req;

//request signal to cpu from cache
logic stall;


//states for CACHE CONTROLLER   
typedef enum logic [2:0] {
    IDLE,PROCESS_REQUEST,CACHE_ALLOCATE,WRITE_BACK,FLUSH
} state_t;
state_t current_state,next_state;



//////////////////////////////// SYNCHRONOUS LOGIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//current state logic 
always_ff @(posedge clk) begin

    if(rst) begin
        current_state<=IDLE;
        latched_read_req<=0;
        latched_write_req<=0;
        latched_flush_req<=0;
        flush_index<=0;       //its basically flush counter
        flush_done<=0;
        cache_to_cpu_data<=0;
        cache_to_main_mem_data<=0;
        for(int i=0;i<256;i++) begin
         data_array[i]<=0;
         tag_array[i]<=0;
         valid[i]<=0;
         dirty[i]<=0;
        end
    end

    else begin
        current_state<=next_state;
    /////////////////////////////////////  FLUSH counter \\\\\\\\\\\\\\\\\\\\\\\\\\
    if (current_state == FLUSH && latched_flush_req) begin
        if (valid[flush_index] && dirty[flush_index]) begin
            cache_to_main_mem_data <= data_array[flush_index];
            if (write_mem_ack) begin
                valid[flush_index] <= 0;
                dirty[flush_index] <= 0;
                if (flush_index == 9'd255) begin
                    flush_done  <= 1;
                    flush_index <= 0;
                end
                else begin
                flush_index <= flush_index + 1;
                end
            end
        end
        else begin
            valid[flush_index] <= 0;
    
            if (flush_index == 9'd255) begin
                flush_done  <= 1;
                flush_index <= 0;
            end
            else begin
                flush_index <= flush_index + 1;
            end
        end
    end
    else begin
        flush_done <= 0;
    end



//////////////////////////// SYNCHRONOUS READ/WRITE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  
        //latching requests just cuz if processor after making request do something else and turn request down so i make sure i capture the request
        if(current_state == IDLE) begin
                latched_read_req<=read_req;
                latched_write_req<=write_req;
                latched_flush_req<=flush_req;
        end
        if (current_state == PROCESS_REQUEST && next_state == IDLE) begin
                 latched_read_req  <= 0;
                 latched_write_req <= 0;
                 latched_flush_req <= 0;
           end

        // in case of read req data will go from cache to cpu (read_hit)
        if(current_state == PROCESS_REQUEST && latched_read_req==1 && cache_hit==1) begin
            cache_to_cpu_data <= data_array[index_bits][offset_bits[3:2]*32 +: 32];
        end 

        // in case of write req data will go from cpu to cache (write_hit)
        if(current_state == PROCESS_REQUEST && latched_write_req==1 && cache_hit==1) begin
            data_array[index_bits][offset_bits[3:2]*32 +: 32]<=cpu_to_cache_data;
            dirty[index_bits]<=1;
        end 

        // in case of read_miss go to main mem bring a block and store in cache at specified index provided by the CPU
        if(current_state == CACHE_ALLOCATE && read_mem_ack==1) begin
            data_array[index_bits] <= main_mem_to_cache_data;
            tag_array[index_bits] <= tag_bits;
            valid[index_bits]<=1;
            dirty[index_bits]      <= (latched_write_req) ? 1 : 0;
        end
       // in case of write_miss go to write the dirty data back to main mem 
        if(current_state== WRITE_BACK && write_mem_ack==1) begin
            cache_to_main_mem_data <= data_array[index_bits];
            dirty[index_bits]<=0;
        end
    end
end

//////////////////////////////////////// NEXT STATE LOGIC \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

always_comb begin
    next_state = current_state;
    stall=0;
    cache_hit=0;
    cache_miss=0;
    read_mem_req=0;
    write_mem_req=0;
    block_address=32'b0;
    
    case (current_state)

    IDLE : begin
        stall=0;
        if(flush_req) next_state = FLUSH;
        else if(read_req==1 || write_req==1) begin //for avaid latency in idle i am checking cpy condition directly not latched one
            next_state = PROCESS_REQUEST;
        end
        else next_state = IDLE;
    end
    
    PROCESS_REQUEST : begin
    //cheking does the required data present in cache (comparing tag bits)
        if(latched_read_req==1) begin
            if(tag_bits == tag_array[index_bits] && valid[index_bits]==1) begin
                stall=0;
                cache_hit=1;
                next_state = IDLE;
            end
            else if (tag_bits != tag_array[index_bits] && valid[index_bits]==0 && dirty[index_bits]==0) begin
                stall=1;
                cache_miss=1;
                next_state = CACHE_ALLOCATE;
            end
            else if (tag_bits != tag_array[index_bits] && valid[index_bits]==0 && dirty[index_bits]==1) begin
                next_state = WRITE_BACK;
            end
        end
        else if (latched_write_req==1) begin
            if(tag_bits == tag_array[index_bits] && valid[index_bits]==1) begin
                stall=0;
                cache_hit=1;
                next_state = IDLE;
            end
            else if (tag_bits != tag_array[index_bits] && dirty[index_bits]==1) begin
                stall=1;
                cache_miss=1;
                next_state = WRITE_BACK;
            end
            else if (tag_bits != tag_array[index_bits] && dirty[index_bits]==0) begin
                next_state = CACHE_ALLOCATE;
            end
        end 
    end
    
    CACHE_ALLOCATE : begin
        stall=1;
        read_mem_req=1;
        block_address = {tag_bits,index_bits,4'b0000};
            if(read_mem_ack==0) next_state = CACHE_ALLOCATE;
            else begin
                next_state = PROCESS_REQUEST;
            end 
    end
    
    WRITE_BACK :begin
        stall=1;
        write_mem_req=1;
        block_address = {tag_array[index_bits],index_bits,4'b0000};
            if(write_mem_ack==0) next_state = WRITE_BACK;
            else begin
                if(flush_req==1) next_state = FLUSH;
                else next_state = CACHE_ALLOCATE;
            end
    end
    FLUSH : begin
        stall=1;
            if(valid[flush_index]==1 && dirty[flush_index]==1) begin
                write_mem_req=1; //trigrin WRITE BACK STATE
                block_address = {tag_array[flush_index],flush_index,4'b0000};
                if(write_mem_ack==1) begin
                    write_mem_req=0;
                end
            end
            else begin
                write_mem_req=0;
            end 
            if(flush_done==1) next_state = IDLE;
            else next_state = FLUSH;
    end
    endcase
end
endmodule
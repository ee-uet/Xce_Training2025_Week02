///////////////////////////////////// Interfase //////////////////////////////////////

interface axi4_lite;
    //READ address chanel
    logic [31:0] ARADDR;
    logic ARVALID;
    logic ARREADY;

    //READ data chanel
    logic [31:0] RDATA;
    logic RVALID;
    logic [1:0]RRESP;
    logic RREADY;

    //WRITE address chanel
    logic [31:0] AWADDR;
    logic AWVALID;
    logic AWREADY;

    //WRITE data chanel
    logic [31:0] WDATA;
    logic WVALID;
    logic WREADY;
    logic [3:0] WSTRB;

    //WRITE response chanel
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;


    modport master (
        output ARADDR,ARVALID,RREADY,AWADDR,AWVALID,WDATA,WVALID,BREADY,WSTRB,
        input ARREADY,RDATA,RVALID,RRESP,AWREADY,WREADY,BVALID,BRESP
    );

    modport slave (
        output ARREADY,RDATA,RVALID,RRESP,AWREADY,WREADY,BVALID,BRESP,
        input ARADDR,ARVALID,RREADY,AWADDR,AWVALID,WDATA,WVALID,BREADY,WSTRB
    );
endinterface




//Combinational logic for decoding the address for write operation

module decoder (
    axi4_lite.slave S,
    output logic valid,invalid,
    output logic [3:0] index
);
//lets say based address is
logic [31:0]base_address = 32'h40000000;
logic  [5:0] offset;
logic [31:0]temp_offset;

always_comb begin
    index=0;
    valid=0;
    invalid=0;
    offset=0;
    temp_offset=0;
    //decoding starts here
    if(S.AWVALID==1) begin
        temp_offset = (S.AWADDR - base_address); // 32-bit subtraction
        offset = temp_offset[5:0]; // Slice to 6-bit
            if((offset[1:0]==2'b00) && (S.AWADDR>=base_address && S.AWADDR<=base_address+32'h3C)) begin
            valid   = 1;
            invalid =  0;
            index   =  (offset>>2);
            end
            else begin
            valid=0;
            invalid=1; //misalligned
            end
            end
    
    else begin
    invalid=1; //out of range
    valid=0;
    end
    end
endmodule






//Combinational logic for decoding the address in case of READ operation
module read_decoder (
    axi4_lite.slave S,
    output logic read_valid,read_invalid,
    output logic [3:0] read_index
);
//lets say base address is
logic [31:0]base_address = 32'h40000000;
logic  [5:0] read_offset;
logic [31:0]temp_offset;

always_comb begin
    read_index=0;
    read_valid=0;
    read_invalid=0;
    read_offset=0;
    temp_offset=0;
    //decoding starts here
    if(S.ARVALID==1) begin
        temp_offset = (S.ARADDR - base_address); // 32-bit subtraction
        read_offset = temp_offset[5:0]; // Slice to 6-bit
            if((read_offset[1:0]==2'b00) && (S.ARADDR >= base_address && S.ARADDR <=  base_address+32'h3C)) begin
            read_valid   = 1;
            read_invalid =  0;
            read_index   =  (read_offset>>2);
            end
            else begin
            read_valid=0;
            read_invalid=1; //misalligned
            end
            end
    
    else begin
    read_invalid=1; //out of range
    read_valid=0;
    end
    end
endmodule






/////////////////////////////// SLAVE MODULE  ///////////////////////////


module axi4_slave (
    //interface loaded in module
    axi4_lite.slave S,
    input logic clk,rst,
    //signals comming from combinational logic which decodes the comming address
    input logic valid,invalid,
    input logic [3:0] index,
    //signals comming from combinational logic which decodes the comming write operations address
    input logic read_valid,read_invalid,
    input logic [3:0] read_index 
);

//internal signals for WRITE operation
logic [31:0] registers [0:15];
logic latched_valid,latched_invalid;
logic  [3:0] latched_index;

//internal sigfnals for read operation
logic latched_valid_read,latched_invalid_read;
logic  [3:0] latched_index_read;

//state for WRITE operation
typedef enum logic [3:0] {
    IDLE,DECODING,WRITE_DATA_WAIT,WRITE_RESPONSE
} state_t;

state_t current_state,next_state;

//states for READ operation
typedef enum logic [3:0] {
    READ_IDLE,READ_DECODING,READ_DATA_WAIT
} read_state_t;
read_state_t read_current_state,read_next_state;





//current state logic
always_ff @(posedge clk)begin
if(rst) begin
    current_state<=IDLE;
    read_current_state<=READ_IDLE;
    latched_index_read<=0;
    latched_valid_read<=0;
    latched_invalid_read<=0;
    latched_index<=0;
    latched_valid<=0;
    latched_invalid<=0;
    for (int i = 0; i < 16; i++) registers[i] <= 32'h0;
end
else begin
    current_state<=next_state;
    read_current_state<=read_next_state;
        
    //latching decoded address for read operation
    if(S.ARVALID==1 && S.ARREADY==1) begin
    latched_index_read<=read_index;
    latched_valid_read<=read_valid;
    latched_invalid_read<=read_invalid;
    end
   
   
    //latching index,valid and invalid
    if(S.AWVALID==1 && S.AWREADY==1) begin
    latched_index<=index;
    latched_valid<=valid;
    latched_invalid<=invalid;
    end

    if(S.WVALID==1 && S.WREADY==1 && latched_valid==1) begin
    registers[latched_index]<=(S.WDATA & {{8{S.WSTRB[3]}}, {8{S.WSTRB[2]}}, {8{S.WSTRB[1]}}, {8{S.WSTRB[0]}}}) | (registers[latched_index] & ~{{8{S.WSTRB[3]}}, {8{S.WSTRB[2]}}, {8{S.WSTRB[1]}}, {8{S.WSTRB[0]}}});
    end   
end
end


//next state logic
always_comb begin
    next_state  = current_state;
    read_next_state  = read_current_state;
    S.ARREADY=0;
    S.RVALID=0;
    S.RRESP=0;
    S.AWREADY=0;
    S.WREADY=0;
    S.BVALID=0;
    S.BRESP=2'b00;
    
    //in reset state all outputs of slave should be known thats why reset here 
    if(rst) begin
    S.ARREADY=1;
    S.RDATA=0;
    S.RVALID=0;
    S.RRESP=0;
    S.AWREADY=1;
    S.WREADY=0;
    S.BVALID=0;
    S.BRESP=2'b00;
    end
    
    
    
    


///////////////////////////// write operation ///////////////////////////////
    case (current_state)
    IDLE : begin
                    S.AWREADY=1;
                    S.WREADY=1;
                    if(S.AWVALID==1) next_state = DECODING;
                end
    DECODING : begin
                    S.AWREADY=0;
                    S.WREADY=0;
                    if(latched_valid==1) next_state = WRITE_DATA_WAIT;
                    else if(latched_invalid==1) next_state = WRITE_RESPONSE;
                    else next_state = IDLE;
                end
    WRITE_DATA_WAIT : begin
                    S.WREADY=1;
                    S.AWREADY=0;
                    if(S.WVALID==1) next_state = WRITE_RESPONSE;
                end
    WRITE_RESPONSE : begin
                        S.WREADY=0;
                        S.AWREADY=0;
                    if(latched_valid==1) begin
                        S.BRESP=2'b00; //OKAY
                        S.BVALID=1;
                        if(S.BREADY==1) next_state = IDLE;
                    end
                    else if(latched_invalid==1) begin
                        S.BRESP=2'b10; //SLAVE ERROR
                        S.BVALID=1;
                        if (S.BREADY==1) next_state = IDLE;
                    end
                end
    endcase
    
    
    
    ////////////////////////////////// read operation ///////////////////////////////
    
    case (read_current_state)
        READ_IDLE : begin
                        S.ARREADY=1;                   
                        if(S.ARVALID==1) read_next_state = READ_DECODING;
                    end
        READ_DECODING : begin
                        S.ARREADY=0;
                        if(latched_valid_read==1) read_next_state = READ_DATA_WAIT;
                        else if(latched_invalid_read==1) read_next_state = READ_DATA_WAIT;
                        else read_next_state=READ_IDLE;
                    end
        READ_DATA_WAIT : begin
                 S.RVALID=1;
                 if (latched_valid_read==1) begin
                      S.RDATA =registers[latched_index_read];
                      S.RRESP=2'b00;
                    if(S.RREADY==1)begin
                       read_next_state = READ_IDLE;
                       end
                 end
                 else if (latched_invalid_read==1) begin
                     S.RRESP=2'b10;//SLAVE ERROR
                     if(S.RREADY==1)begin
                         read_next_state = READ_IDLE;
                     end
                 end
                 end 
        endcase    
end
endmodule










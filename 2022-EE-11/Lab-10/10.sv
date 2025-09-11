interface axi4_lite_if;
    // Write address channel
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;
    
    // Write data channel  
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;
    
    // Write response channel
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;
    
    // Read address channel
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;
    
    // Read data channel
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;
    
    // Modports for master and slave
    
    modport master (
        output awaddr, awvalid, wdata, wstrb, wvalid, bready,
               araddr, arvalid, rready,
        input  awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );
    
    modport slave (
        input  awaddr, awvalid, wdata, wstrb, wvalid, bready,
               araddr, arvalid, rready,
        output awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
    );
    
endinterface

module axi4_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    axi4_lite_if.slave  axi_if
);

    // Register bank - 16 x 32-bit registers
    logic [31:0] register_bank [0:15];
    
    // Address decode
    logic [3:0] write_addr_index, read_addr_index;
    logic       addr_valid_write, addr_valid_read;
    
    // State machines for read and write channels
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;
    
    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;
    
    write_state_t c_write_state, n_write_state;
    read_state_t  c_read_state, n_read_state;
    
    // TODO: Implement write channel state machine
    // Consider: Outstanding transaction handling
    always_ff @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    		c_write_state	<= #1 W_IDLE;
    	end else begin
    		c_write_state	<= #1 n_write_state;
    	end
    end
    
    always_comb begin
    	axi_if.wready			= 0;
    	axi_if.awready			= 0;
    	axi_if.bvalid			= 0;
    	axi_if.bresp			= 0;
    	
    	n_write_state		= c_write_state;
    	
    	case(c_write_state) 
    		W_IDLE: begin
    			if(axi_if.awvalid) begin
    				n_write_state	= W_ADDR;
    			end
    		end
    		W_ADDR: begin
    			axi_if.awready	= 1;
    			if(axi_if.awvalid) begin
    				n_write_state	= W_DATA;
    			end
    		end
    		W_DATA: begin
    			axi_if.wready	= 1;
    			if(axi_if.wvalid) begin
    				n_write_state	= W_RESP;
    			end
    		end
    		W_RESP: begin
    			axi_if.bvalid	= 1;
    			axi_if.bresp	= 2'b00;
    			if(axi_if.bready) begin
    				n_write_state	= W_IDLE;
    			end
    		end
    	endcase
    end
    
    // TODO: Implement read channel state machine  
    // Consider: Read data pipeline timing
	
    always_ff @(posedge clk or negedge rst_n) begin
    	if(~rst_n) begin
    		c_read_state	<= #1 R_IDLE;
    	end else begin
    		c_read_state	<= #1 n_read_state;
    	end
    end
    
    always_comb begin
    	axi_if.rvalid			= 0;
    	axi_if.arready			= 0;
    	axi_if.rresp			= 0;
    	
    	n_read_state		= c_read_state;
    	
    	case(c_read_state) 
    		R_IDLE: begin
    			if(axi_if.arvalid) begin
    				n_read_state	= R_ADDR;
    			end
    		end
    		R_ADDR: begin
    			axi_if.arready	= 1;
    			if(axi_if.arvalid) begin
    				n_read_state	= R_DATA;
    			end
    		end
    		R_DATA: begin
    			axi_if.rvalid	= 1;
    			axi_if.rresp	= 2'b00;
    			if(axi_if.rready) begin
    				n_read_state	= R_IDLE;
    			end
    		end
    	endcase
    end
	
    // TODO: Implement address decode logic
    // Consider: What constitutes a valid address?
    
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			write_addr_index	<= #1 0;
		end else begin
			if(addr_valid_write) begin
				write_addr_index	<= #1 axi_if.awaddr[5:2];
			end
		end
	end
    
    assign addr_valid_write	= axi_if.awvalid & axi_if.awready;
    
    	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			read_addr_index	<= #1 0;
		end else begin
			if(addr_valid_read) begin
				read_addr_index	<= #1 axi_if.araddr[5:2];
			end
		end
	end
    
    assign addr_valid_read	= axi_if.arvalid & axi_if.arready;
    
    // TODO: Implement register bank
    // Consider: Which registers are read-only vs read-write?
    
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			for(int i = 0; i < 16; i++) begin
                		register_bank[i] <= #1 32'h0;  // Fixed: Proper initialization
			end
		end else begin
			if(axi_if.wvalid & axi_if.wready) begin
				case(axi_if.wstrb) 
					4'b0001: register_bank[write_addr_index][7:0]	<= #1 axi_if.wdata[7:0];
					4'b0010: register_bank[write_addr_index][15:8]	<= #1 axi_if.wdata[15:8];
					4'b0100: register_bank[write_addr_index][23:16]	<= #1 axi_if.wdata[23:16];
					4'b1000: register_bank[write_addr_index][31:24]	<= #1 axi_if.wdata[31:24];
					default: register_bank[write_addr_index]	<= #1 axi_if.wdata;
				endcase
			end
		end
	end

     assign axi_if.rdata = (axi_if.rvalid) ? register_bank[read_addr_index] : 0;
     
endmodule

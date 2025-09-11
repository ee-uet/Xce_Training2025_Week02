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
    
    write_state_t write_state;
    read_state_t  read_state;
    
    // TODO: Implement write channel state machine
    // Consider: Outstanding transaction handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_state       <= W_IDLE;
            axi_if.awready    <= 1'b0;
            axi_if.wready     <= 1'b0;
            axi_if.bvalid     <= 1'b0;
            axi_if.bresp      <= 2'b00;
			write_addr_index  <= 4'b0;
			addr_valid_write  <= 1'b0; 
        end 
		else begin
			case (write_state)
				W_IDLE: begin
                    axi_if.wready  <= 0;
                    axi_if.bvalid  <= 0;
                    if (axi_if.awvalid) begin
                        write_state <= W_ADDR;
						axi_if.awready    <= 1; // ready to accept address
                    end
					else begin
					write_state <= W_IDLE;
					end
				end
				
				W_ADDR: begin
                    write_addr_index  <= axi_if.awaddr[5:2]; // word-aligned
                    addr_valid_write  <= (axi_if.awaddr[5:2] < 16);
					axi_if.wready     <= 1; // wait for write data
					write_state       <= W_DATA;
                end
				W_DATA: begin
					axi_if.awready    <= 0;
					
					if (axi_if.wvalid) begin
                        if (addr_valid_write) begin
                            for (int i = 0; i < 4; i++) begin
                                if (axi_if.wstrb[i]) begin
                                    register_bank[write_addr_index][i*8 +: 8] 
                                        <= axi_if.wdata[i*8 +: 8];
								end
                            end
						end             
						axi_if.wready   <= 0;
						axi_if.bvalid   <= 1;
                        write_state     <= W_RESP;
                    end
					else begin
						write_state     <= W_DATA;
					end
				end
				
				
				W_RESP: begin
					
					
                    if (axi_if.bready && addr_valid_write) begin
						axi_if.bresp    <= 2'b00; // OKAY
                    end
					else begin
						axi_if.bresp    <= 2'b10; // SLVERR
					end
					write_state     <= W_IDLE;
                end
				
				default: begin
					write_state <= W_IDLE;
				end
			
			endcase
		end
	end
    
	// TODO: Implement read channel state machine  
    // Consider: Read data pipeline timing
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			read_state       <= R_IDLE;
            axi_if.arready   <= 0;
            axi_if.rvalid    <= 0;
            axi_if.rdata     <= 0;
            axi_if.rresp     <= 2'b00;
			read_addr_index  <= 4'b0;
			addr_valid_read  <= 1'b0;
		end
		else begin
			case (read_state) 
				R_IDLE: begin
                    
                    if (axi_if.arvalid) begin
						axi_if.arready <= 1; // ready for read address
                        read_addr_index <= (axi_if.araddr[5:2]);
                        addr_valid_read <= (axi_if.araddr[5:2] < 16);
                        read_state      <= R_ADDR;
                    end
                end
				
				R_ADDR: begin
                    axi_if.arready   <= 0;
                    if (addr_valid_read) begin
                        axi_if.rdata <= register_bank[read_addr_index];
                        axi_if.rvalid <= 1;
						axi_if.rresp <= 2'b00; // OKAY
                    end else begin
                        axi_if.rdata <= 32'hDEADBEEF; // invalid addr marker
                        axi_if.rresp <= 2'b10; // SLVERR
                    end
                    read_state <= R_DATA;
                end
				
				R_DATA: begin
                    if (axi_if.rready) begin
                        axi_if.rvalid <= 0;
                        read_state    <= R_IDLE;
                    end
                end
				
				default: begin
					read_state <= R_IDLE;
				end
			endcase
		end
	end
    
    // TODO: Implement address decode logic
    // Consider: What constitutes a valid address?
    
    // TODO: Implement register bank
    // Consider: Which registers are read-only vs read-write?

endmodule


typedef enum logic [1:0] {
  IDLE  = 2'b00,
  READ  = 2'b01,
  WRITE = 2'b10,
  DONE  = 2'b11
} state_t;


module sram_fsm (
  input  logic clk,
  input  logic rst_n,
  input  logic read_req,
  input  logic write_req,

  output logic ready,
  output logic latch_addr,
  output logic latch_data,
  output logic latch_read,
  output logic drive_data_en,

  output logic sram_ce_n,
  output logic sram_oe_n,
  output logic sram_we_n
);


state_t current_state, next_state;
    
    // State register - ALWAYS separate this
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic 
always_comb begin
  next_state = current_state;

  unique case (current_state)
    IDLE: begin
      
      if (write_req)      next_state = WRITE;
      else if (read_req)  next_state = READ;
      else                next_state = IDLE;
    end
    READ:   next_state = DONE;   
    WRITE:  next_state = DONE;   
    DONE:   next_state = IDLE;   
    default: next_state = IDLE;
  endcase
end
always_comb begin 
  
  ready          = 1'b0;
  latch_addr     = 1'b0;
  latch_data     = 1'b0;
  latch_read     = 1'b0;
  drive_data_en  = 1'b0;

  sram_ce_n      = 1'b1; // Active low
  sram_oe_n      = 1'b1; // Active low
  sram_we_n      = 1'b1; // Active low

  unique case (current_state)
    IDLE: begin
      ready      = 1'b1;
      sram_ce_n  = 1'b1;
    end
    READ: begin
      ready = 1'b0;
      latch_addr = 1'b1; 
      sram_ce_n  = 1'b0; 
      sram_oe_n  = 1'b0; 
      latch_read = 1'b1; 
      latch_data = 1'b0;
      drive_data_en = 1'b0; 
    end
    WRITE: begin
      latch_addr    = 1'b1; 
      latch_data    = 1'b1; 
      latch_read    = 1'b0; 
      drive_data_en = 1'b1; 
      sram_ce_n     = 1'b0;
      sram_we_n     = 1'b0; 
    end
    DONE: begin
      sram_ce_n = 1'b1; 
      sram_we_n  = 1'b1;
      drive_data_en = 1'b1;
      sram_oe_n  = 1'b1;
    end
    default: begin
      ready      = 1'b0;
      sram_ce_n  = 1'b1; 
    end
  endcase
end
    // Output logic - Separate from state logic
    // TO: Implement Moore or Mealy outputs

endmodule


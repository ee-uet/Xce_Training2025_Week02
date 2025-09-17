typedef enum logic [1:0] {
  IDLE  = 2'b00,
  READ  = 2'b01,
  WRITE = 2'b10,
  DONE  = 2'b11
} state_t;

module Sram_fsm (
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
    
    // state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    // next-state logic
    always_comb begin
        next_state = current_state;
        unique case (current_state)
            IDLE: begin
                if (write_req)      next_state = WRITE;
                else if (read_req)  next_state = READ;
            end
            READ:   next_state = DONE;   
            WRITE:  next_state = DONE;   
            DONE:   next_state = IDLE;   
        endcase
    end

    // outputs
    always_comb begin 
        // defaults
        ready          = 0;
        latch_addr     = 0;
        latch_data     = 0;
        latch_read     = 0;
        drive_data_en  = 0;

        sram_ce_n      = 1; // active low
        sram_oe_n      = 1;
        sram_we_n      = 1;

        unique case (current_state)
            IDLE: begin
                ready = 1; // wait for req
            end
            READ: begin
                latch_addr = 1;   // capture addr
                sram_ce_n  = 0;   // chip enable
                sram_oe_n  = 0;   // sram drives data
                latch_read = 1;   // latch sram output
                // drive_data_en = 0 here (CPU not driving bus)
            end
            WRITE: begin
                latch_addr    = 1; // capture addr
                latch_data    = 1; // capture cpu data
                drive_data_en = 1; // cpu drives bus
                sram_ce_n     = 0;
                sram_we_n     = 0; // write strobe
            end
            DONE: begin
                // cleanup cycle, no bus drive
                sram_ce_n = 1;
            end
        endcase
    end

endmodule

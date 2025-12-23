module wptr_handler #(parameter PTR_WIDTH=3) (
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH:0] g_rptr_sync, // Synced Gray read pointer from read domain
  output logic [PTR_WIDTH:0] b_wptr, g_wptr,
  output logic full
);

  logic [PTR_WIDTH:0] b_wptr_next;
  logic [PTR_WIDTH:0] g_wptr_next;
  logic wfull;
  
  // Binary and Gray code pointers for the NEXT state
  assign b_wptr_next = b_wptr + (w_en & !full); // Increment only if not full and write enable
  assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next; // Binary to Gray conversion
  
  // Convert synced Gray read pointer to binary for comparison
  logic [PTR_WIDTH:0] b_rptr_sync;
  g2b_converter #(PTR_WIDTH) g2b_wr (.gray_in(g_rptr_sync), .bin_out(b_rptr_sync));
  
  // Full condition logic
  logic wrap_around;
  assign wrap_around = b_rptr_sync[PTR_WIDTH] ^ b_wptr_next[PTR_WIDTH]; // Check if MSBs are different
  assign wfull = wrap_around & (b_wptr_next[PTR_WIDTH-1:0] == b_rptr_sync[PTR_WIDTH-1:0]); // Check if lower bits are equal

  // Register updates
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      b_wptr <= '0;
      g_wptr <= '0;
    end else begin
      b_wptr <= b_wptr_next;
      g_wptr <= g_wptr_next;
    end
  end
  
  // Full flag register
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) 
      full <= 1'b0;
    else        
      full <= wfull;
  end

endmodule
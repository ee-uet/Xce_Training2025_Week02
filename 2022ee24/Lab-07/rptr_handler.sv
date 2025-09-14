module rptr_handler #(parameter PTR_WIDTH=3) (
  input rclk, rrst_n, r_en,
  input [PTR_WIDTH:0] g_wptr_sync, // Synced Gray write pointer from write domain
  output logic [PTR_WIDTH:0] b_rptr, g_rptr,
  output logic empty
);

  logic [PTR_WIDTH:0] b_rptr_next;
  logic [PTR_WIDTH:0] g_rptr_next;
  logic rempty;
  
  // Binary and Gray code pointers for the NEXT state
  assign b_rptr_next = b_rptr + (r_en & !empty); // Increment only if not empty and read enable
  assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next; // Binary to Gray conversion
  
  // Convert synced Gray write pointer to binary for comparison
  logic [PTR_WIDTH:0] b_wptr_sync;
  g2b_converter #(PTR_WIDTH) g2b_rd (.gray_in(g_wptr_sync), .bin_out(b_wptr_sync));
  
  // Empty condition is simple equality check of binary pointers
  assign rempty = (b_wptr_sync == b_rptr_next);

  // Register updates
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      b_rptr <= '0;
      g_rptr <= '0;
    end else begin
      b_rptr <= b_rptr_next;
      g_rptr <= g_rptr_next;
    end
  end
  
  // Empty flag register
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) 
      empty <= 1'b1;
    else        
      empty <= rempty;
  end

endmodule
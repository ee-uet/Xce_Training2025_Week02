module asynchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input  logic wclk, wrst_n,
  input  logic rclk, rrst_n,
  input  logic w_en, r_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic  full, empty
);
logic [$clog2(DEPTH)-1:0] b_wptr,b_wptr_next,g_wptr,g_wptr_next,g_wptr_sync;
logic [$clog2(DEPTH)-1:0] b_rptr,b_rptr_next,g_rptr,g_rptr_next,g_rptr_sync;

assign b_wptr_next = b_wptr+(w_en & !full);
assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
assign full=(((b_wptr+1) >>1)^(b_wptr+1))==g_rptr_sync;
always_ff @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) begin
    b_wptr <= 0; // set default value
    g_wptr <= 0;
  end
  else begin
    b_wptr <= b_wptr_next; // incr binary write pointer
    g_wptr <= g_wptr_next; // incr gray write pointer
  end
end



assign b_rptr_next = b_rptr+(r_en & !empty);
assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
assign empty = (g_wptr_sync == g_rptr);

always_ff @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) begin
    b_rptr <= 0;
    g_rptr <= 0;
  end
  else begin
    b_rptr <= b_rptr_next;
    g_rptr <= g_rptr_next;
  end
end

synchronizer #(DEPTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync); //write pointer to read clock domain
synchronizer #(DEPTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync); //read pointer to write clock domain


logic [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  
  always@(posedge wclk) begin
    if(w_en & !full) begin
      fifo[b_wptr] <= data_in;
    end
  end

  assign data_out = fifo[b_rptr];
endmodule
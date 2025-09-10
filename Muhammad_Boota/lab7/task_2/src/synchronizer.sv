module synchronizer #(parameter DEPTH=8) (
    input logic clk, rst_n, 
    input logic [$clog2(DEPTH)-1:0] d_in, 
    output logic [$clog2(DEPTH)-1:0]d_out
    );
  logic [$clog2(DEPTH)-1:0] q1;
    
  always@(posedge clk) begin
    if(!rst_n) begin
      q1 <= 0;
      d_out <= 0;
    end
    else begin
      q1 <= d_in;
      d_out <= q1;
    end
  end
endmodule
module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)
(
    input  logic                   r_rst_n,
    input  logic                   w_rst_n,
    input  logic                   wr_clk,
    input  logic                   wr_en,
    input  logic [WIDTH-1:0]       wr_data,
    output logic                   full,
    input  logic                   rd_clk,
    input  logic                   rd_en,
    output logic [WIDTH-1:0]       rd_data,
    output logic                   empty  
);

logic [WIDTH-1:0] mem [0:DEPTH-1];
logic [$clog2(DEPTH):0] wr_ptr, rd_ptr; // One bit wider for full/empty detection
logic [$clog2(DEPTH):0] wr_ptr_gray, rd_ptr_gray;
logic [$clog2(DEPTH):0] wr_ptr_gray_sync_rdclk, rd_ptr_gray_sync_wrclk;
logic [$clog2(DEPTH):0] wr_ptr_binary, rd_ptr_binary;

// Write Pointer
always_ff @(posedge wr_clk ) begin
    if (!w_rst_n) begin
        wr_ptr <= 0;
        
    end 
    else if (wr_en && !full) begin
        mem[wr_ptr[$clog2(DEPTH)-1:0]] <= wr_data; // lower bits for addressing
        wr_ptr <= wr_ptr + 1;
        
    end
end

always_comb begin
    if ((wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr_binary[$clog2(DEPTH)-1:0]) && ~wr_ptr[$clog2(DEPTH)] == rd_ptr_binary[$clog2(DEPTH)] ) begin
        full = 1;
    end
    else begin
        full = 0;
    end
end

always_comb begin 
    wr_ptr_gray = {wr_ptr[$clog2(DEPTH)], wr_ptr[$clog2(DEPTH):1] ^ wr_ptr[$clog2(DEPTH)-1:0]};
    
end

synchronizer #(.N($clog2(DEPTH))) sync1 ( 
    .clk_dest(rd_clk),
    .rst_n(w_rst_n),
    .data_in(wr_ptr_gray),
    .data_out(wr_ptr_gray_sync_rdclk)
);

always_comb begin 
    wr_ptr_binary[$clog2(DEPTH)] = wr_ptr_gray_sync_rdclk[$clog2(DEPTH)];
    for (int i = $clog2(DEPTH)-1; i >= 0; i--) begin
        wr_ptr_binary[i] = wr_ptr_gray_sync_rdclk[i] ^ wr_ptr_binary[i+1];
    end
end
// Read Pointer module
always_ff @(posedge rd_clk) begin
    if (!r_rst_n) begin
        rd_ptr <= 0;
    end 
    else if (rd_en && !empty) begin
        rd_data <= mem[rd_ptr[$clog2(DEPTH)-1:0]]; // lower bits for addressing
        rd_ptr <= rd_ptr + 1;
        
    end
end

always_comb begin
    if ((rd_ptr[$clog2(DEPTH)-1:0] == wr_ptr_binary[$clog2(DEPTH)-1:0]) && (rd_ptr[$clog2(DEPTH)] == wr_ptr_binary[$clog2(DEPTH)])) begin
        empty = 1;
    end
    else begin
        empty = 0;
    end
end

always_comb begin 
    rd_ptr_gray = {rd_ptr[$clog2(DEPTH)], rd_ptr[$clog2(DEPTH):1] ^ rd_ptr[$clog2(DEPTH)-1:0]};
    
end

synchronizer #(.N($clog2(DEPTH))) sync2 ( 
    .clk_dest(wr_clk),
    .rst_n(r_rst_n),
    .data_in(rd_ptr_gray),
    .data_out(rd_ptr_gray_sync_wrclk)
);


always_comb begin 
    rd_ptr_binary[$clog2(DEPTH)] = rd_ptr_gray_sync_wrclk[$clog2(DEPTH)];
    for (int i = $clog2(DEPTH)-1; i >= 0; i--) begin
        rd_ptr_binary[i] = rd_ptr_gray_sync_wrclk[i] ^ rd_ptr_binary[i+1];
    end
end

endmodule
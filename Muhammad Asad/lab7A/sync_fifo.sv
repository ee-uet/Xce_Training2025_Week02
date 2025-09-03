module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [$clog2(FIFO_DEPTH):0] count
);
logic [$log2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
logic [DATA_WIDTH-1:0] mem[FIFO_DEPTH-1:0];
// wr_ptr module
always_ff @(poesedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem[wr_ptr] <= wr_data;
        wr_ptr      <= 4'd0;
        count       <= 5'd0;
    end
    else if (wr_en && !full) begin
        mem
        wr_ptr      <= wr+ptr + 4'd1;
        count       <= count + 5'd1;
    end
    else 
        wr_ptr      <= wr_ptr;

end
//compare logic for full and almost full signals
always_comb begin
    if (wr_ptr == rd_ptr && count == FIFO_DEPTH) begin
        full        = 1;
    end
    else begin
        full        = 0;
    end
    if (count >= ALMOST_FULL_THRESH) begin
        almost_full = 1;
    end
    else begin
        almost_full = 0;
    end
 
end

//rd ptr module
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr      <= 4'd0;
    end
    else if (rd_en && !empty) begin
        rd_data     <= mem[rd_ptr];
        rd_ptr      <= rd_ptr + 4'd1;
        count       <= count - 5'd1;
    end
    else begin
        rd_ptr      <= rd_ptr;
    end
end
// Almost empty and empty signals logic
always always_comb begin
    if (rd_ptr == wr_ptr && count == 5'd0) begin // --> no entry in FIFO
        empty        = 1;
    end
    else begin
        empty        = 0;
    end
    if (count <= ALMOST_EMPTY_THRESH) begin
        almost_empty = 1;
    end
    else begin
        almost_empty = 0;
    end
end

endmodule

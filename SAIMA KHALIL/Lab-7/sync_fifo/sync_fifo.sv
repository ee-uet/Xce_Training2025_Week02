module sync_fifo #(
    parameter int DATA_WIDTH = 16,
    parameter int FIFO_DEPTH = 8,
    parameter int ALMOST_FULL_THRESH  = FIFO_DEPTH-2,  // e.g. depth-2
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                     clk,
    input  logic                     reset,
    input  logic                     wr_en,
    input  logic                     rd_en,
    input  logic [DATA_WIDTH-1:0]    data_in,
    output logic [DATA_WIDTH-1:0]    data_out,
    output logic                     full,
    output logic                     empty,
    output logic                     almost_full,
    output logic                     almost_empty,
    output logic [$clog2(FIFO_DEPTH+1)-1:0] count
);

    // Memory
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(FIFO_DEPTH+1)-1:0] count_q;

    // Flags
    always_comb begin
        full         = (count_q == FIFO_DEPTH);
        empty        = (count_q == 0);
        almost_full  = (count_q >= ALMOST_FULL_THRESH);
        almost_empty = (count_q <= ALMOST_EMPTY_THRESH);
    end

    // FIFO write/read logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr   <= 0;
            rd_ptr   <= 0;
            count_q  <= 0;
            data_out <= '0;
        end else begin
            // Write logic
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= (wr_ptr == FIFO_DEPTH - 1) ? 0 : wr_ptr + 1;
            end
            // Read logic
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == FIFO_DEPTH - 1) ? 0 : rd_ptr + 1;
            end else begin
                data_out <= '0;
            end
        end 
    end

    // Count update
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q <= 0;
        end else begin
            if (wr_en && !rd_en && !full)
                count_q <= count_q + 1;
            else if (!wr_en && rd_en && !empty)
                count_q <= count_q - 1;
            else if (wr_en && rd_en && !full && !empty)
                count_q <= count_q; // no change
        end
    end

    assign count = count_q;

endmodule

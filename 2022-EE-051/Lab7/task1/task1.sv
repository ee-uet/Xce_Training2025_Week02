module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter ALMOST_EMPTY_THRESHOLD = 2,
    parameter ALMOST_FULL_THRESHOLD  = 14
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic empty,
    output logic almost_empty,
    output logic full,
    output logic almost_full,
    output logic [$clog2(FIFO_DEPTH):0] count
);

    // Memory
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            // Write
            if (wr_en && (count < FIFO_DEPTH)) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
            // Read
            if (rd_en && (count > 0)) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

    // Flags
    assign empty        = (count == 0);
    assign almost_empty = (count > 0) && (count <= ALMOST_EMPTY_THRESHOLD);

    assign full         = (count == FIFO_DEPTH);
    assign almost_full  = (count >= ALMOST_FULL_THRESHOLD) && (count < FIFO_DEPTH);

endmodule

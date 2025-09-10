module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic rd_en,
    output logic [DATA_WIDTH-1:0] dout,
    output logic empty,
    output logic full
);

    // Widths
    localparam int PTR_W = $clog2(FIFO_DEPTH);

    // Memory
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    logic [PTR_W-1:0] wr_ptr, rd_ptr;
    logic [PTR_W:0] count; // allow count up to FIFO_DEPTH

    // Default output
    assign empty = (count == 0);
    assign full  = (count == FIFO_DEPTH);

    // Sequential read/write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            dout   <= '0;
        end else begin
            // Write (if space)
            if (wr_en && (count < FIFO_DEPTH)) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end

            // Read (if available)
            if (rd_en && (count > 0)) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule


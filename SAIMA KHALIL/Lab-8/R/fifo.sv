module fifo #(
    parameter WIDTH = 9,     // word width (data size + frame_error)
    parameter DEPTH = 8       // fifo depth (no. of entries)
)(
    input  logic clk,
    input  logic reset,
    input  logic wr_en,
    input  logic rd_en,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

    // Memory array
    logic [WIDTH-1:0] mem [DEPTH-1:0];

    // Pointers and counter
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH+1)-1:0] count_q;

    // Full & empty flags
    always_comb begin
        full  = (count_q == DEPTH);
        empty = (count_q == 0);
    end

    // FIFO logic (write + read)
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
                wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1;
            end
            // Read logic
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1;
            end else begin
                data_out <= '0;  // keep output zero if not reading
            end
        end
    end

    // Counter update
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q <= 0;
        end else begin
            if (wr_en && !rd_en && !full)
                count_q <= count_q + 1;
            else if (!wr_en && rd_en && !empty)
                count_q <= count_q - 1;
            // wr+rd at same time → count unchanged
        end
    end

endmodule

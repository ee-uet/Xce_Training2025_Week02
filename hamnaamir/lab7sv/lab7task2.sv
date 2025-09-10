module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                    wr_clk,
    input  logic                    rd_clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty
);

    logic [DATA_WIDTH-1:0]  fifomem [FIFO_DEPTH-1:0];

    // pointers
    logic [$clog2(FIFO_DEPTH)-1:0] wr_pointer, rd_pointer;
    logic [$clog2(FIFO_DEPTH)-1:0] grey_wr_ptr, grey_rd_ptr;

    // sync pointers
    logic [$clog2(FIFO_DEPTH)-1:0] sync_rd_stage1, sync_rd_stage2; // read -> write
    logic [$clog2(FIFO_DEPTH)-1:0] sync_wr_stage1, sync_wr_stage2; // write -> read

    // --- Gray to Binary conversion ---
    function automatic logic [$clog2(FIFO_DEPTH)-1:0] gray2bin(
        input logic [$clog2(FIFO_DEPTH)-1:0] g
    );
        logic [$clog2(FIFO_DEPTH)-1:0] b;
        int i;
        b[$clog2(FIFO_DEPTH)-1] = g[$clog2(FIFO_DEPTH)-1];
        for (i = $clog2(FIFO_DEPTH)-2; i >= 0; i--) begin
            b[i] = b[i+1] ^ g[i];
        end
        return b;
    endfunction

    // --- write ---
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_pointer     <= 0;
            grey_wr_ptr    <= 0;
            sync_rd_stage1 <= 0;
            sync_rd_stage2 <= 0;
        end else begin
            // write mem
            if (wr_en && !full) begin
                fifomem[wr_pointer] <= wr_data;
                wr_pointer <= (wr_pointer + 1) % FIFO_DEPTH;
            end

            // gray code
            grey_wr_ptr <= wr_pointer ^ (wr_pointer >> 1);

            // sync read
            sync_rd_stage1 <= grey_rd_ptr;
            sync_rd_stage2 <= sync_rd_stage1;
        end
    end

    // --- read ---
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_pointer     <= 0;
            grey_rd_ptr    <= 0;
            sync_wr_stage1 <= 0;
            sync_wr_stage2 <= 0;
        end else begin
            // read mem
            if (rd_en && !empty) begin
                rd_data <= fifomem[rd_pointer];
                rd_pointer <= (rd_pointer + 1) % FIFO_DEPTH;
            end

            // gray code
            grey_rd_ptr <= rd_pointer ^ (rd_pointer >> 1);

            // sync write
            sync_wr_stage1 <= grey_wr_ptr;
            sync_wr_stage2 <= sync_wr_stage1;
        end
    end

    // --- flags using if-else ---
    always_comb begin
        logic [$clog2(FIFO_DEPTH)-1:0] synced_rd_bin, synced_wr_bin;

        // FIX: convert synced Gray pointers to binary
        synced_rd_bin = gray2bin(sync_rd_stage2);
        synced_wr_bin = gray2bin(sync_wr_stage2);

        // full
        if (((wr_pointer + 1) % FIFO_DEPTH) == synced_rd_bin)
            full = 1;
        else
            full = 0;

        // empty
        if (rd_pointer == synced_wr_bin)
            empty = 1;
        else
            empty = 0;

        // almost full
        if (((wr_pointer + 1) % FIFO_DEPTH) >= ((synced_rd_bin + ALMOST_FULL_THRESH) % FIFO_DEPTH))
            almost_full = 1;
        else
            almost_full = 0;

        // almost empty
        if (((rd_pointer + ALMOST_EMPTY_THRESH) % FIFO_DEPTH) >= synced_wr_bin)
            almost_empty = 1;
        else
            almost_empty = 0;
    end

endmodule

module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,

    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,

    output logic                  full,
    output logic                  empty
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // -----------------------------
    // FIFO Memory
    // -----------------------------
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // -----------------------------
    // Binary & Gray Pointers
    // -----------------------------
    logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray, rd_ptr_bin, rd_ptr_gray;
    logic [ADDR_WIDTH:0] wr_ptr_bin_next, rd_ptr_bin_next;
    logic [ADDR_WIDTH:0] wr_ptr_gray_next, rd_ptr_gray_next;

    // -----------------------------
    // Pointer Synchronization
    // -----------------------------
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync_wr, wr_ptr_gray_sync_rd;

    // Sync function: 2-flop synchronizer
    function automatic [ADDR_WIDTH:0] sync_flop(
        input logic clk, input logic rst_n, input logic [ADDR_WIDTH:0] din
    );
        logic [ADDR_WIDTH:0] s1, s2;
        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                s1 <= '0;
                s2 <= '0;
            end else begin
                s1 <= din;
                s2 <= s1;
            end
        end
        return s2;
    endfunction

    // -----------------------------
    // Write Logic
    // -----------------------------
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1); // binary→Gray
        end
    end

    // -----------------------------
    // Read Logic
    // -----------------------------
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
        end else if (rd_en && !empty) begin
            rd_data     <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // -----------------------------
    // Pointer Synchronization
    // -----------------------------
    // (In practice, use separate always_ff with flops, not function like this)
    // Example simplified:
    always_ff @(posedge wr_clk or negedge wr_rst_n)
        if (!wr_rst_n) rd_ptr_gray_sync_wr <= '0;
        else rd_ptr_gray_sync_wr <= rd_ptr_gray;

    always_ff @(posedge rd_clk or negedge rd_rst_n)
        if (!rd_rst_n) wr_ptr_gray_sync_rd <= '0;
        else wr_ptr_gray_sync_rd <= wr_ptr_gray;

    // -----------------------------
    // Empty & Full flags
    // -----------------------------
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync_rd);
    assign full  = (wr_ptr_gray_next == {~rd_ptr_gray_sync_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                                         rd_ptr_gray_sync_wr[ADDR_WIDTH-2:0]});

endmodule
module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    // Write side
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,

    // Read side
    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,

    // Status
    output logic                  full,
    output logic                  empty
);

    // ---------------------------------
    // Parameters & Local Constants
    // ---------------------------------
    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // ---------------------------------
    // FIFO Memory
    // ---------------------------------
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // ---------------------------------
    // Binary & Gray Pointers
    // ---------------------------------
    logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
    logic [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;
    logic [ADDR_WIDTH:0] wr_ptr_bin_next, wr_ptr_gray_next;
    logic [ADDR_WIDTH:0] rd_ptr_bin_next, rd_ptr_gray_next;

    // ---------------------------------
    // Pointer Synchronization
    // ---------------------------------
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync_wr;
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync_rd;

    // ---------------------------------
    // Write Logic
    // ---------------------------------
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1); // binary → Gray
        end
    end

    // ---------------------------------
    // Read Logic
    // ---------------------------------
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

    // ---------------------------------
    // Pointer Synchronization
    // ---------------------------------
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) 
            rd_ptr_gray_sync_wr <= '0;
        else 
            rd_ptr_gray_sync_wr <= rd_ptr_gray;
    end

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) 
            wr_ptr_gray_sync_rd <= '0;
        else 
            wr_ptr_gray_sync_rd <= wr_ptr_gray;
    end

    // ---------------------------------
    // Empty & Full flags
    // ---------------------------------
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync_rd);

    assign full  = (wr_ptr_gray_next == {
                        ~rd_ptr_gray_sync_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                         rd_ptr_gray_sync_wr[ADDR_WIDTH-2:0]
                    });

endmodule

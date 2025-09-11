module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  full,

    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  empty
);

    // Memory
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH];

    // Write pointer
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_bin, wr_ptr_gray;
    logic [$clog2(FIFO_DEPTH):0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    logic [$clog2(FIFO_DEPTH):0] rd_ptr_bin_sync;

    // Read pointer
    logic [$clog2(FIFO_DEPTH):0] rd_ptr_bin, rd_ptr_gray;
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    logic [$clog2(FIFO_DEPTH):0] wr_ptr_bin_sync;

    // Gray code conversion
    function automatic logic [$clog2(FIFO_DEPTH):0] bin_to_gray(input logic [$clog2(FIFO_DEPTH):0] bin);
        return bin ^ (bin >> 1);
    endfunction

    function automatic logic [$clog2(FIFO_DEPTH):0] gray_to_bin(input logic [$clog2(FIFO_DEPTH):0] gray);
        logic [$clog2(FIFO_DEPTH):0] bin;
        bin = gray;
        for (int i = $clog2(FIFO_DEPTH); i > 0; i--)
            bin[i-1] = bin[i] ^ gray[i-1];
        return bin;
    endfunction

    // Write domain logic
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[$clog2(FIFO_DEPTH)-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= bin_to_gray(wr_ptr_bin + 1);
        end
    end

    // Read domain logic
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            rd_data     <= 0;
        end else if (rd_en && !empty) begin
            rd_data     <= mem[rd_ptr_bin[$clog2(FIFO_DEPTH)-1:0]];
            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= bin_to_gray(rd_ptr_bin + 1);
        end
    end

    // Synchronize read pointer into write domain
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Synchronize write pointer into read domain
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // Convert synchronized gray pointers to binary
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_bin_sync <= 0;
        end else begin
            rd_ptr_bin_sync <= gray_to_bin(rd_ptr_gray_sync2);
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_bin_sync <= 0;
        end else begin
            wr_ptr_bin_sync <= gray_to_bin(wr_ptr_gray_sync2);
        end
    end

    // Generate full flag in write domain
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            full <= 0;
        end else begin
            full <= ((wr_ptr_bin + 1) == rd_ptr_bin_sync);
        end
    end

    // Generate empty flag in read domain
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            empty <= 1;
        end else begin
            empty <= (rd_ptr_bin == wr_ptr_bin_sync);
        end
    end

endmodule

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter ALMOST_EMPTY_THRESHOLD = 2,
    parameter ALMOST_FULL_THRESHOLD  = 14
)(
    input  logic wr_clk,
    input  logic rd_clk,
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

    // Write and Read binary pointers
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr_bin, rd_ptr_bin;
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr_gray, rd_ptr_gray;

    // Synchronized pointers for cross-domain
    logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

    // Count signals
    logic [$clog2(FIFO_DEPTH):0] wr_count, rd_count;

    // Write domain logic

    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin] <= wr_data;
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
        end
    end

    // Read domain logic

    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            rd_data     <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr_bin];
            rd_ptr_bin <= rd_ptr_bin + 1;
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // Pointer synchronization across domain

    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // Gray to binary conversion

    function automatic [$clog2(FIFO_DEPTH)-1:0] gray2bin(input [$clog2(FIFO_DEPTH)-1:0] gray);
        integer i;
        begin
            gray2bin[$clog2(FIFO_DEPTH)-1] = gray[$clog2(FIFO_DEPTH)-1];
            for (i=$clog2(FIFO_DEPTH)-2; i>=0; i=i-1)
                gray2bin[i] = gray[i] ^ gray2bin[i+1];
        end
    endfunction

    logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr_bin_sync, wr_ptr_bin_sync;
    assign rd_ptr_bin_sync = gray2bin(rd_ptr_gray_sync2);
    assign wr_ptr_bin_sync = gray2bin(wr_ptr_gray_sync2);

    // Count calculation

    always_comb begin
        if (wr_ptr_bin >= rd_ptr_bin_sync)
            wr_count = wr_ptr_bin - rd_ptr_bin_sync;
        else
            wr_count = FIFO_DEPTH + wr_ptr_bin - rd_ptr_bin_sync;

        if (wr_ptr_bin_sync >= rd_ptr_bin)
            rd_count = wr_ptr_bin_sync - rd_ptr_bin;
        else
            rd_count = FIFO_DEPTH + wr_ptr_bin_sync - rd_ptr_bin;
    end

    // Flags using

    always_comb begin
        if (wr_count == FIFO_DEPTH)
            full = 1;
        else
            full = 0;

        if ((wr_count >= ALMOST_FULL_THRESHOLD) && (wr_count < FIFO_DEPTH))
            almost_full = 1;
        else
            almost_full = 0;
    end

    always_comb begin
        if (rd_count == 0)
            empty = 1;
        else
            empty = 0;

        if ((rd_count > 0) && (rd_count <= ALMOST_EMPTY_THRESHOLD))
            almost_empty = 1;
        else
            almost_empty = 0;
    end

    assign count = rd_count;

endmodule

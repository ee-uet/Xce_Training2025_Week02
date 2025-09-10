module Async_FIFO #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ADDR_WIDTH = $clog2(FIFO_DEPTH),
    parameter int PTR_WIDTH  = ADDR_WIDTH + 1 // +1 for full/empty detect
)(
    // Write Clock Domain
    input  logic                   wr_clk,
    input  logic                   wr_rst_n,
    input  logic                   wr_en,
    input  logic [DATA_WIDTH-1:0]  wr_data,
    output logic                   full,

    // Read Clock Domain
    input  logic                   rd_clk,
    input  logic                   rd_rst_n,
    input  logic                   rd_en,
    output logic [DATA_WIDTH-1:0]  rd_data,
    output logic                   empty
);

    // Memory
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

    // Binary and Gray Pointers
    logic [PTR_WIDTH-1:0] wr_bin, rd_bin;
    logic [PTR_WIDTH-1:0] wr_gray, rd_gray;

    // Synced Pointers
    logic [PTR_WIDTH-1:0] wr_gray_synced, rd_gray_synced;

    
    // Write Side
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n)
            wr_bin <= '0;
        else if (wr_en && !full) begin
            mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data; // Write data to memory at binary pointer
            wr_bin <= wr_bin + 1'b1;
        end
    end

    assign wr_gray = wr_bin ^ (wr_bin >> 1); // Convert binary write pointer to Gray code

    // Sync rd_gray into wr_clk domain
    logic [PTR_WIDTH-1:0] rd_gray_sync1, rd_gray_sync2;
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_gray_sync1 <= '0;
            rd_gray_sync2 <= '0;
        end else begin
            rd_gray_sync1 <= rd_gray; // First stage of 2-stage synchronizer
            rd_gray_sync2 <= rd_gray_sync1; // Second stage for stable read pointer
        end
    end
    assign rd_gray_synced = rd_gray_sync2;

    assign full = (wr_gray == {~rd_gray_synced[PTR_WIDTH-1], 
                               rd_gray_synced[PTR_WIDTH-2:0]}); // Full condition: pointers differ only in MSB

    
    // Read Side
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n)
            rd_bin <= '0;
        else if (rd_en && !empty)
            rd_bin <= rd_bin + 1'b1;
    end

    assign rd_gray = rd_bin ^ (rd_bin >> 1); // Convert binary read pointer to Gray code

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n)
            rd_data <= '0;
        else if (rd_en && !empty)
            rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]]; // Read data from memory at binary pointer
    end

    // Sync wr_gray into rd_clk domain
    logic [PTR_WIDTH-1:0] wr_gray_sync1, wr_gray_sync2;
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_gray_sync1 <= '0;
            wr_gray_sync2 <= '0;
        end else begin
            wr_gray_sync1 <= wr_gray; // First stage of 2-stage synchronizer
            wr_gray_sync2 <= wr_gray_sync1; // Second stage for stable write pointer
        end
    end
    assign wr_gray_synced = wr_gray_sync2;

    assign empty = (rd_gray == wr_gray_synced); // Empty condition: pointers are equal

endmodule
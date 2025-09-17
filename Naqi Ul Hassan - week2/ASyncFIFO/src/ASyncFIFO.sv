module ASyncFIFO #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic                   rst_n,

    // Write domain
    input  logic                   wr_clk,
    input  logic                   wr_en,
    input  logic [WIDTH-1:0]       wr_data,
    output logic                   full,
    
    // Read domain
    input  logic                   rd_clk,
    input  logic                   rd_en,
    output logic [WIDTH-1:0]       rd_data,
    output logic                   empty
);

    // Memory
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Binary + Gray pointers
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0] wr_ptr_gray, rd_ptr_gray;
    logic [$clog2(DEPTH):0] wr_ptr_gray_sync_rdclk, rd_ptr_gray_sync_wrclk;

    // ================= WRITE SIDE =================
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end 
        else if (wr_en && !full) begin
            mem[wr_ptr[$clog2(DEPTH)-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Binary → Gray conversion for write pointer
    B2G #(.N($clog2(DEPTH)+1)) b2g_wr (
        .binary (wr_ptr),
        .gray   (wr_ptr_gray)
    );

    // Sync read pointer Gray into write clock domain
    Syncgen #(.N($clog2(DEPTH)+1)) sync_rd2wr (
        .clk_dest(wr_clk),
        .rst_n(rst_n),
        .data_in(rd_ptr_gray),
        .data_out(rd_ptr_gray_sync_wrclk)
    );

    // Full logic
    always_comb begin
        full = (wr_ptr_gray == {~rd_ptr_gray_sync_wrclk[$clog2(DEPTH):$clog2(DEPTH)-1],
                                rd_ptr_gray_sync_wrclk[$clog2(DEPTH)-2:0]});
    end

    // ================= READ SIDE =================
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= '0;
            rd_data <= '0;
        end 
        else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[$clog2(DEPTH)-1:0]];
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

    // Binary → Gray conversion for read pointer
    B2G #(.N($clog2(DEPTH)+1)) b2g_rd (
        .binary(rd_ptr),
        .gray(rd_ptr_gray)
    );

    // Sync write pointer Gray into read clock domain
    Syncgen #(.N($clog2(DEPTH)+1)) sync_wr2rd (
        .clk_dest(rd_clk),
        .rst_n(rst_n),
        .data_in(wr_ptr_gray),
        .data_out(wr_ptr_gray_sync_rdclk)
    );

    // Empty logic
    always_comb begin
        empty = (rd_ptr_gray == wr_ptr_gray_sync_rdclk);
    end

endmodule

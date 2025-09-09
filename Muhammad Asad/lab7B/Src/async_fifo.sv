module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)
(
    input  logic                   rst_n,

    input  logic                   wr_clk,
    input  logic                   wr_en,
    input  logic [WIDTH-1:0]       wr_data,
    output logic                   full,
    
    input  logic                   rd_clk,
    input  logic                   rd_en,
    output logic [WIDTH-1:0]       rd_data,
    output logic                   empty
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;         // One extra bit for full/empty detection
    logic [$clog2(DEPTH):0] wr_ptr_gray, rd_ptr_gray;
    logic [$clog2(DEPTH):0] wr_ptr_gray_sync_rdclk, rd_ptr_gray_sync_wrclk;

    
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end 
        else if (wr_en && !full) begin
            mem[wr_ptr[$clog2(DEPTH)-1:0]] <= wr_data; // lower bits for addressing
            wr_ptr <= wr_ptr + 1;
        end
    end

    
    always_comb begin
        full = (wr_ptr_gray == {~rd_ptr_gray_sync_wrclk[$clog2(DEPTH):$clog2(DEPTH)-1], rd_ptr_gray_sync_wrclk[$clog2(DEPTH)-2:0]});
    end

    binary2gray #(.N($clog2(DEPTH)+1)) b2g_inst1 (
        .binary(wr_ptr),
        .gray(wr_ptr_gray)
    );

    synchronizer #(.N($clog2(DEPTH)+1)) sync1 ( 
        .clk_dest(rd_clk),
        .rst_n(rst_n),
        .data_in(wr_ptr_gray),
        .data_out(wr_ptr_gray_sync_rdclk)
    );

   
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data <= 0;  
        end 
        else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[$clog2(DEPTH)-1:0]]; // lower bits for addressing
            rd_ptr <= rd_ptr + 1;
        end
    end

  
    always_comb begin
        empty = (rd_ptr_gray == wr_ptr_gray_sync_rdclk);
    end

    binary2gray #(.N($clog2(DEPTH)+1)) b2g_inst2 (
        .binary(rd_ptr),
        .gray(rd_ptr_gray)
    );

    synchronizer #(.N($clog2(DEPTH)+1)) sync2 ( 
        .clk_dest(wr_clk),
        .rst_n(rst_n),
        .data_in(rd_ptr_gray),
        .data_out(rd_ptr_gray_sync_wrclk)
    );

endmodule

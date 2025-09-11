module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
)(
    input  logic                  wr_clk, //write side clk
    input  logic                  rd_clk, //read side clk
    input  logic                  rst_n,  //active low reset
    input  logic                  wr_en,  //a signal to write
    input  logic [DATA_WIDTH-1:0] wr_data,//data ti write
    input  logic                  rd_en,  //signal to read
    output logic [DATA_WIDTH-1:0] rd_data,//data that is read
    output logic                  full,   //fifo full flag
    output logic                  empty   //fifo empty flag
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);  // address width = 4

    // Memory
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1]; //creating memory (16 blocks of 8 bits)

    // Binary + Gray Pointers
    logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray; //binary and gray forms of write pointer
    logic [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray; //binary and gray forms of read pointer

    logic [ADDR_WIDTH:0] wr_ptr_gray_sync_rd; // wr ptr synchronized into rd domain
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync_wr; // rd ptr synchronized into wr domain

    // Binary to Gray conversion
    function automatic [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin); //automatic: new stack for every call
        return (bin >> 1) ^ bin; //right shift by 1 and XOR
    endfunction

    // Write Pointer Logic
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
        end
    end


    // Read Pointer Logic
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
            rd_data     <= '0;
        end else if (rd_en && !empty) begin
            rd_data     <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
        end
    end

    // Synchronizers
    logic [ADDR_WIDTH:0] wr_ptr_gray_rd_sync_ff [1:0];  //2 flip-flops for space clk domain crossing
    logic [ADDR_WIDTH:0] rd_ptr_gray_wr_sync_ff [1:0];  //5,5 bits each. 1 extra bit for full flag

    // wr pointer into rd domain
    always_ff @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_gray_rd_sync_ff[0] <= '0;
            wr_ptr_gray_rd_sync_ff[1] <= '0;
        end else begin
            wr_ptr_gray_rd_sync_ff[0] <= wr_ptr_gray;
            wr_ptr_gray_rd_sync_ff[1] <= wr_ptr_gray_rd_sync_ff[0];
        end
    end
    assign wr_ptr_gray_sync_rd = wr_ptr_gray_rd_sync_ff[1];

    // rd pointer into wr domain
    always_ff @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_gray_wr_sync_ff[0] <= '0;
            rd_ptr_gray_wr_sync_ff[1] <= '0;
        end else begin
            rd_ptr_gray_wr_sync_ff[0] <= rd_ptr_gray;
            rd_ptr_gray_wr_sync_ff[1] <= rd_ptr_gray_wr_sync_ff[0];
        end
    end
    assign rd_ptr_gray_sync_wr = rd_ptr_gray_wr_sync_ff[1];

    // Empty flag (read domain)
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync_rd);

    // Full flag (write domain)
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                                   rd_ptr_gray_sync_wr[ADDR_WIDTH-2:0]});

endmodule


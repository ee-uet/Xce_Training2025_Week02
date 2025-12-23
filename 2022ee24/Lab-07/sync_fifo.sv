module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [$clog2(FIFO_DEPTH):0] count
);

    // Local parameters
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
    localparam PTR_WIDTH = ADDR_WIDTH + 1; // Extra bit for full/empty detection
    
    // Internal signals
    logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
    
    // Memory declaration
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    
    // Pointer update logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end else begin
            // Write pointer update
            if (wr_en && !full) begin
                wr_ptr <= wr_ptr + 1;
            end
            
            // Read pointer update
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
    
    // Memory write operation
    always_ff @(posedge clk) begin
        if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end
    
    // Memory read operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        end
    end
    
    
    assign count = wr_ptr - rd_ptr;
    assign almost_full  = (count >= ALMOST_FULL_THRESH);
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH);
    assign empty = (wr_ptr == rd_ptr);
    assign full = (wr_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]) && 
                  (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);


endmodule
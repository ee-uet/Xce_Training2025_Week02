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
    logic [PTR_WIDTH-1:0] count_int;
    
    // Memory declaration (inferred block RAM)
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
    
    // Memory read operation (registered output)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        end
    end
    
    // Element count calculation
    assign count_int = wr_ptr - rd_ptr;
    
    // Flag generation (registered to avoid glitches)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full          <= 1'b0;
            empty         <= 1'b1;
            almost_full   <= 1'b0;
            almost_empty  <= 1'b1;
            count         <= '0;
        end else begin
            // Update count output
            count <= count_int;
            
            // Full: MSB different, lower address bits equal
            full <= (wr_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]) && 
                    (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
            
            // Empty: pointers are identical
            empty <= (wr_ptr == rd_ptr);
            
            // Almost full/empty based on thresholds
            almost_full  <= (count_int >= ALMOST_FULL_THRESH);
            almost_empty <= (count_int <= ALMOST_EMPTY_THRESH);
        end
    end

endmodule
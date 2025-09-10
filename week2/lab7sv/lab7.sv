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

    logic [DATA_WIDTH-1:0]  fifomem [FIFO_DEPTH-1:0];
    int wr_pointer;
    int rd_pointer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_pointer   <= 0;
            rd_pointer   <= 0;
            count        <= 0;
        end else begin
            // --- Write operation ---
            if (wr_en && (count < FIFO_DEPTH)) begin
                fifomem[wr_pointer] <= wr_data;
                wr_pointer <= (wr_pointer + 1) % FIFO_DEPTH;
            end

            // --- Read operation ---
            if (rd_en && (count > 0)) begin
                rd_data <= fifomem[rd_pointer];
                rd_pointer <= (rd_pointer + 1) % FIFO_DEPTH;
            end
    
            // --- Count update ---
            if (wr_en && !rd_en && (count < FIFO_DEPTH))begin
                count <= count + 1;
            end    
            else if (!wr_en && rd_en && (count > 0))begin
                count <= count - 1;
            end    
            // If both read and write happen simultaneously, count stays the same
        end
    end

       // --- Flags (derived from count) ---
    always_comb begin
        if (count == 0) begin
            empty        = 1;
            full         = 0;
            almost_full  = 0;
            almost_empty = 1;
        end
        else if (count == FIFO_DEPTH) begin
            empty        = 0;
            full         = 1;
            almost_full  = 1;
            almost_empty = 0;
        end
        else if (count >= ALMOST_FULL_THRESH) begin
            empty        = 0;
            full         = 0;
            almost_full  = 1;
            almost_empty = 0;
        end
        else if (count <= ALMOST_EMPTY_THRESH) begin
            empty        = 0;
            full         = 0;
            almost_full  = 0;
            almost_empty = 1;
        end
        else begin
            empty        = 0;
            full         = 0;
            almost_full  = 0;
            almost_empty = 0;
        end
    end
 

endmodule

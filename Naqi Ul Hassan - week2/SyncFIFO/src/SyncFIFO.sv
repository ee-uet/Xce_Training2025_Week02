module SyncFIFO #(
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

    // Pointers
    logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end 
        else if (wr_en && !full) begin
            mem[wr_ptr] <= wr_data;
            if (wr_ptr == FIFO_DEPTH-1)
                wr_ptr <= '0;
            else
                wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= '0;
            rd_data <= '0;
        end 
        else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];
            if (rd_ptr == FIFO_DEPTH-1)
                rd_ptr <= '0;
            else
                rd_ptr <= rd_ptr + 1;
        end
    end

    // Count update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end 
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; // write only
                2'b01: count <= count - 1; // read only
                default: count <= count;   // hold
            endcase
        end
    end

    // Status flags
    always_comb begin
        empty         = (count == 0);
        full          = (count == FIFO_DEPTH);
        almost_empty  = (count <= ALMOST_EMPTY_THRESH);
        almost_full   = (count >= ALMOST_FULL_THRESH);
    end

endmodule

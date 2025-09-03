module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH  = 14,
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
    output logic [$clog2(FIFO_DEPTH):0] count   // can represent 0..DEPTH
);

    // ---------------------------------------------------------
    // Local parameters
    // ---------------------------------------------------------
    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // ---------------------------------------------------------
    // Internal signals
    // ---------------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0]; // FIFO storage
    logic [ADDR_WIDTH-1:0] w_ptr, r_ptr;        // pointers

    // ---------------------------------------------------------
    // Write logic
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr <= '0;
        end else if (wr_en && !full) begin
            mem[w_ptr] <= wr_data;              // write data
            w_ptr <= (w_ptr + 1'b1);            // increment pointer
        end
    end

    // ---------------------------------------------------------
    // Read logic
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_ptr   <= '0;
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[r_ptr];              // read data
            r_ptr   <= (r_ptr + 1'b1);          // increment pointer
        end
    end

    // ---------------------------------------------------------
    // Count logic
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;   // write only
                2'b01: count <= count - 1'b1;   // read only
                default: count <= count;        // no change or both active
            endcase
        end
    end

    // ---------------------------------------------------------
    // Flag generation (registered for glitch-free operation)
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full         <= 1'b0;
            empty        <= 1'b1;
            almost_full  <= 1'b0;
            almost_empty <= 1'b1;
        end else begin
            full         <= (count == FIFO_DEPTH);
            empty        <= (count == 0);
            almost_full  <= (count >= ALMOST_FULL_THRESH);
            almost_empty <= (count <= ALMOST_EMPTY_THRESH);
        end
    end

endmodule

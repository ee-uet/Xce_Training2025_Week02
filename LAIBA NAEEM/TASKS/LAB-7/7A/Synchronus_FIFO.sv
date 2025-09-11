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

    // FIFO storage
    logic [DATA_WIDTH-1:0] memory [FIFO_DEPTH-1:0];
    logic [$clog2(FIFO_DEPTH)-1:0] write_pointer, read_pointer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= 0;
            write_pointer <= 0;
            read_pointer <= 0;
            count <= 0;
            full <= 0;
            empty <= 1;
            almost_full <= 0;
            almost_empty <= 1;
        end
        else begin
            // Write operation
            if (wr_en && !full) begin
                memory[write_pointer] <= wr_data;
                write_pointer <= (write_pointer + 1) % FIFO_DEPTH;
                count <= count + 1;
            end

            // Read operation
            if (rd_en && !empty) begin
                rd_data <= memory[read_pointer];
                read_pointer <= (read_pointer + 1) % FIFO_DEPTH;
                count <= count - 1;
            end

            // Flags
            full <= (count == FIFO_DEPTH);
            empty <= (count == 0);
            almost_full <= (count >= ALMOST_FULL_THRESH);
            almost_empty <= (count <= ALMOST_EMPTY_THRESH);
        end
    end
endmodule

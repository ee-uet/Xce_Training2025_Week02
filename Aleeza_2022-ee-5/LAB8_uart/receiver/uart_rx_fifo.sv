module uart_rx_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16,
    parameter int ALMOST_FULL_THRESH  = FIFO_DEPTH-2,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                    clk,
    input  logic                    reset_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic                    almost_full,
    output logic                    almost_empty,
    output logic [$clog2(FIFO_DEPTH):0] count   // one extra bit for depth
);


    // Internal signals
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];  
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;

    // FIFO Count
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) 
            count <= '0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; // write only
                2'b01: count <= count - 1; // read only
                default: count <= count;   // both or none
            endcase
        end
    end

// write logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= '0;
            end
        else if (wr_en && !full)begin
            wr_ptr <= wr_ptr + 1'b1;
            mem[wr_ptr] <= wr_data;
    end
    end

    // Read logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rd_ptr <= '0;
            rd_data <= '0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr];
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

    // Flag Generation
    assign full         = (count == FIFO_DEPTH);
    assign empty        = (count == 0);
    assign almost_full  = (count >= ALMOST_FULL_THRESH);
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH);

endmodule



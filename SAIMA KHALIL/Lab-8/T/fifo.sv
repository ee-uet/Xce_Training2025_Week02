module fifo #(parameter DEPTH = 8)
(
    input  logic clk,
    input  logic reset,
    input  logic wr_en,
    input  logic rd_en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic full,
    output logic empty
);

    logic [15:0] mem [DEPTH-1:0];
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH+1)-1:0] count_q;

    // Full & empty flags
    always_comb begin
        full  = (count_q == DEPTH);
        empty = (count_q == 0);
    end

    // FIFO logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr   <= 0;
            rd_ptr   <= 0;
            count_q  <= 0;
            data_out <= 0;
        end else begin
            // Write logic
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1;
            end
            // Read logic
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1;
            end else begin
                data_out <= 16'b0;  
            end
        end 
    end
   always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        wr_ptr   <= 0;
        rd_ptr   <= 0;
        count_q  <= 0;
        data_out <= 0;
    end else begin
        // Write
        if (wr_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1;
            count_q <= count_q + 1;
        end

        // Read
        if (rd_en && !empty) begin
            data_out <= mem[rd_ptr];
            rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1;
            count_q <= count_q - 1;
        end else if (!(rd_en && !empty)) begin
            data_out <= data_out; // hold last value
        end
    end
end


endmodule

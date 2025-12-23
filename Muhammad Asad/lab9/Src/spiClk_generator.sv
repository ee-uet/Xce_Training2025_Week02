module spiClk_generator (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [15:0] div_val,   
    input logic         cpol,
    input logic         start_clk,
    output logic        spi_clk   
);

    logic [15:0] count;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count         <= 0;
            if (cpol) begin
                spi_clk <= 1'b1;
            end
            else begin
                spi_clk <= 1'b0;
            end
        end else if (start_clk) begin
                if (count == div_val - 1) begin
                    count         <= 0;
                    spi_clk <= ~spi_clk; 
                end else begin
                    count <= count + 1;
                end
        end
        else begin
            count <= 0;
            if (cpol) begin
                spi_clk <= 1'b1;
            end
            else begin
                spi_clk <= 1'b0;
            end
        end
    end

endmodule
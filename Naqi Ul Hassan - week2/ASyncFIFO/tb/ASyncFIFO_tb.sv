module ASyncFIFO_tb;

    parameter WIDTH = 8;
    parameter DEPTH = 16;

    logic               rst_n;
    logic               wr_clk, rd_clk;
    logic               wr_en, rd_en;
    logic [WIDTH-1:0]   wr_data;
    logic               full, empty;
    logic [WIDTH-1:0]   rd_data;

    // DUT
    ASyncFIFO #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .rst_n      (rst_n),
        .wr_clk     (wr_clk),
        .wr_en      (wr_en),
        .wr_data    (wr_data),
        .full       (full),
        .rd_clk     (rd_clk),
        .rd_en      (rd_en),
        .rd_data    (rd_data),
        .empty      (empty)
    );

    // write clock
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;

    // read clock
    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk; 

    // Monitor activity
    initial begin
        $monitor("T=%0t | wr_clk=%b wr_en=%b wr_data=%h full=%b | rd_clk=%b rd_en=%b rd_data=%h empty=%b",
                  $time, wr_clk, wr_en, wr_data, full, rd_clk, rd_en, rd_data, empty);
    end

    initial begin
        // Init
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = 0;
        #3;
        rst_n   = 1;

        // Write 5 values
        repeat (5) begin
            @(posedge wr_clk);
            wr_en   <= 1;
            wr_data <= wr_data + 8'hA;
        end
        @(posedge wr_clk);
        wr_en <= 0;

        // Read 5 values
        repeat (5) begin
            @(posedge rd_clk);
            rd_en <= 1;
        end
        @(posedge rd_clk);
        rd_en <= 0;

        // Extra cycles for stability
        repeat (5) @(posedge rd_clk);
        
        $finish;
    end

endmodule

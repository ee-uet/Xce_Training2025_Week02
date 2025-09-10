module tb_async_fifo;
    logic        r_rst_n, w_rst_n;
    logic        wr_clk, rd_clk;
    logic        wr_en, rd_en;
    logic [7:0]  wr_data, rd_data;
    logic        full, empty;

    // Instantiate DUT
    async_fifo #(
        .WIDTH(8),
        .DEPTH(16)
    ) UUT (
        .r_rst_n(r_rst_n),
        .w_rst_n(w_rst_n),
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock generation - different frequencies
    initial wr_clk = 0;
    always #5 wr_clk = ~wr_clk;   // 100MHz
    
    initial rd_clk = 0;
    always #7 rd_clk = ~rd_clk;   // ~71MHz

    initial begin
        // Initialize
        w_rst_n = 0;
        r_rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        
        #20;
        w_rst_n = 1;
        r_rst_n = 1;
        #30;
        
        // Write some data
        repeat(8) begin
            @(posedge wr_clk);
            wr_data = wr_data + 1;
            wr_en = 1;
            @(posedge wr_clk);
            wr_en = 0;
        end
        
        #50;
        
        // Read data back
        repeat(5) begin
            @(posedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            rd_en = 0;
        end
        
        #100;
        
        // Fill FIFO
        repeat(16) begin
            @(posedge wr_clk);
            wr_data = wr_data + 1;
            wr_en = 1;
            @(posedge wr_clk);
            wr_en = 0;
        end
        
        #100;
        $finish;
    end

endmodule
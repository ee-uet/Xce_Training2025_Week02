module uart_transmitter #( 
    parameter int CLK_FREQ   = 50000000, 
    parameter int BAUD_RATE  = 115200, 
    parameter int FIFO_DEPTH = 8 
)( 
    input  logic       clk, 
    input  logic       rst_n,
    input  logic [7:0] tx_data, 
    input  logic       tx_valid, 
    output logic       tx_ready, 
    output logic       tx_serial,
    output logic baud_tick,
    output logic       tx_busy 
); 

    wire f_full, f_empty;
    wire f_rd_en, f_wr_en;
    wire [7:0] data_out;
    wire s_load, s_shift;
    wire s_empty, done;
    wire [3:0] count_d;

    // Baud rate generator
    baud inst_baud (
        .clk     (clk), 
        .rst_n   (rst_n),
        .baud_clk(baud_tick)
    );

    // FIFO
    fifo #(.DEPTH(FIFO_DEPTH)) fifo_module (
        .clk     (baud_tick),
        .reset   (rst_n),
        .wr_en   (f_wr_en),
        .rd_en   (f_rd_en),
        .data_in (tx_data),
        .data_out(data_out),
        .full    (f_full),
        .empty   (f_empty)
    );

    // FIFO Controller
    fifo_controller f_cont (
        .clk     (baud_tick),
        .rst     (rst_n),
        .tx_valid(tx_valid),
        .f_full  (f_full),
        .f_empty (f_empty),
        .tx_ready(tx_ready),
        .wr_en   (f_wr_en),
        .rd_en   (f_rd_en)
    );

    // Shift register
    shiftRegister shift_module (
 
        .reset(rst_n),
        .data     (data_out),
        .s_load   (s_load),
        .s_shift  (s_shift),
 
        .s_empty  (s_empty),
        .baud_clk(baud_tick),
        .count_q  (count_d),
        .tx_serial(tx_serial)
    );

    // Shift register controller
    shiftreg_controller s_contr (
        .clk      (clk),
        .rst      (rst_n),
        .s_empty  (s_empty),
        .f_rd_en  (f_rd_en),
        .baud_tick(baud_tick),
        .count_d  (count_d),
        .s_shift  (s_shift),
        .s_load   (s_load),
        .done     (done)
    );

    // Busy signal
    assign tx_busy = !s_empty || !f_empty;

endmodule

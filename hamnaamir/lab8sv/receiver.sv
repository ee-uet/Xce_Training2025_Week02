module uart_rx #(
    parameter int DATA_BITS = 8,
    parameter int BAUD_TICK_COUNT = 16,   
    parameter int FIFO_DEPTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rx,
    input  logic rd_en,                              
    output logic [DATA_BITS-1:0] rx_out,
    output logic rx_valid,                           
    output logic fifo_empty,
    output logic fifo_full
);

    // Baud Generator
    logic baud_tick;
    logic [$clog2(BAUD_TICK_COUNT)-1:0] baud_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt <= '0;
            baud_tick <= 1'b0;
        end else begin
            if (baud_cnt == BAUD_TICK_COUNT-1) begin
                baud_cnt <= '0;
                baud_tick <= 1'b1;    // one-clock pulse
            end else begin
                baud_cnt <= baud_cnt + 1;
                baud_tick <= 1'b0;
            end
        end
    end

    // Receiver State Machine and shift register
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    logic [$clog2(DATA_BITS)-1:0] bit_idx;
    logic [DATA_BITS-1:0] shift_reg;

    logic fifo_wr_en;
    logic [DATA_BITS-1:0] fifo_din;
    logic [DATA_BITS-1:0] fifo_dout;

    // FSM: sampled on baud_tick
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_idx <= '0;
            shift_reg <= '0;
            fifo_wr_en <= 1'b0;
            fifo_din <= '0;
        end else begin
            fifo_wr_en <= 1'b0;

            if (baud_tick) begin
                case (state)
                    IDLE: begin
                        // wait for start bit
                        if (!rx) begin
                            state <= START;
                        end
                    end

                    START: begin
                        if (!rx) begin
                            state <= DATA;
                            bit_idx <= '0;
                            shift_reg <= '0;
                        end else begin
                            // false start, go back
                            state <= IDLE;
                        end
                    end

                    DATA: begin
                        shift_reg[bit_idx] <= rx;
                        if (bit_idx == DATA_BITS-1) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end

                    STOP: begin
                        if (rx) begin
                            fifo_din <= shift_reg;
                            fifo_wr_en <= 1'b1;
                        end
                        state <= IDLE;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end

    // FIFO instance
    fifo #(
        .DATA_WIDTH(DATA_BITS),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) rx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(fifo_wr_en),
        .din(fifo_din),
        .rd_en(rd_en),
        .dout(fifo_dout),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    // Data Register
    logic [DATA_BITS-1:0] data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= '0;
            rx_valid <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            if (rd_en && !fifo_empty) begin
                data_reg <= fifo_dout;
                rx_valid <= 1'b1;
            end
        end
    end

    assign rx_out = data_reg;

endmodule

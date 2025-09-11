module uart_tx #(
    parameter int WIDTH        = 8,
    parameter int DEPTH        = 16,
    parameter int CLK_FREQ     = 50_000_000,  
    parameter int BAUD_RATE    = 115200,   
    parameter int PARITY_MODE  = 0 // 0=None, 1=Even, 2=Odd
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              wr_en,
    input  logic [WIDTH-1:0]  tx_data,
    output logic              tx_serial,
    output logic              busy,
    output logic              fifo_full,
    output logic              fifo_empty,
    output logic              tx_ready
);

    // Data Register
    logic [WIDTH-1:0] data_reg;
    logic             data_reg_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg       <= '0;
            data_reg_valid <= 1'b0;
        end else begin
            if (wr_en && !fifo_full) begin
                data_reg       <= tx_data;
                data_reg_valid <= 1'b1; // means there is new data to push into fifo
            end else begin
                data_reg_valid <= 1'b0;  
            end
        end
    end

    // FIFO 
    logic [WIDTH-1:0] fifo_dout;
    logic             rd_en;


    sync_fifo #(
    .DATA_WIDTH(8),
    .FIFO_DEPTH(16)
) u_fifo (
    .clk        (clk),
    .rst_n      (rst_n),
    .wr_en      (data_reg_valid && !fifo_full),
    .rd_en      (rd_en),
    .wr_data    (data_reg),       // changed from .din
    .rd_data    (fifo_dout),      // changed from .dout
    .full       (fifo_full),
    .almost_full(),                // optional, can leave unconnected
    .empty      (fifo_empty),
    .almost_empty()                // optional, can leave unconnected
);


    assign tx_ready = ~fifo_full;

    // Baud Tick Generator 
    localparam int BAUD_TICK = CLK_FREQ / BAUD_RATE;
    logic [$clog2(BAUD_TICK)-1:0] baud_cnt;
    logic baud_tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= '0;
            baud_tick <= 1'b0;
        end else begin
            if (baud_cnt == BAUD_TICK-1) begin
                baud_cnt  <= '0;
                baud_tick <= 1'b1;
            end else begin
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= 1'b0;
            end
        end
    end

    // FSM states 
    typedef enum logic [2:0] {
        S_IDLE,
        S_LOAD,
        S_START_BIT,
        S_DATA_BITS,
        S_PARITY_BIT,
        S_STOP_BIT
    } state_t;

    state_t state, state_n;

    logic [WIDTH-1:0] shift_reg;
    logic [$clog2(WIDTH+1)-1:0] bit_index;
    logic tx_out_reg;
    logic frame_active;
    logic parity_bit;

    assign tx_serial = tx_out_reg;
    assign busy      = frame_active;

    // Sequential Logic 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= S_IDLE;
            tx_out_reg   <= 1'b1;
            shift_reg    <= '0;
            bit_index    <= '0;
            frame_active <= 1'b0;
            parity_bit   <= 1'b0;
        end else begin
            state <= state_n;

            case (state)

                S_IDLE: begin
                    tx_out_reg   <= 1'b1;
                    frame_active <= 1'b0;
                end

                S_LOAD: begin
                    shift_reg    <= fifo_dout;
                    bit_index    <= 0;
                    frame_active <= 1'b1;
                    tx_out_reg   <= 1'b1;
                    // Calculate parity based on mode
                    case (PARITY_MODE)
                        1: parity_bit <= ^fifo_dout;     // Even parity
                        2: parity_bit <= ~(^fifo_dout);  // Odd parity
                        default: parity_bit <= 1'b0;     // No parity
                    endcase
                end

                S_START_BIT: if (baud_tick) begin
                    tx_out_reg <= 1'b0;
                end

                S_DATA_BITS: if (baud_tick) begin
                    tx_out_reg <= shift_reg[bit_index];
                    bit_index  <= bit_index + 1;
                end

                S_PARITY_BIT: if (baud_tick) begin
                    tx_out_reg <= parity_bit;
                end

                S_STOP_BIT: if (baud_tick) begin
                    tx_out_reg   <= 1'b1;
                    frame_active <= 1'b0;
                end
            endcase
        end
    end

    // Next State Logic 
    always_comb begin
        state_n = state;
        rd_en   = 1'b0;

        case (state)
            S_IDLE: begin
                if (!fifo_empty) begin
                    state_n = S_LOAD;
                    rd_en   = 1'b1;
                end
            end

            S_LOAD:      state_n = S_START_BIT;

            S_START_BIT: if (baud_tick) state_n = S_DATA_BITS;

            S_DATA_BITS: if (baud_tick && (bit_index == WIDTH-1)) begin
                if (PARITY_MODE == 0)
                    state_n = S_STOP_BIT;
                else
                    state_n = S_PARITY_BIT;
            end

            S_PARITY_BIT: if (baud_tick) state_n = S_STOP_BIT;

            S_STOP_BIT: if (baud_tick) begin
                if (!fifo_empty) begin
                    state_n = S_LOAD;
                    rd_en   = 1'b1;
                end else
                    state_n = S_IDLE;
            end
        endcase
    end

endmodule
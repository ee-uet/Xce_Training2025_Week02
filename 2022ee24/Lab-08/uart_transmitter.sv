
module uart_transmitter #(
    parameter int CLK_FREQ = 50_000_000,    // 50MHz system clock
    parameter int BAUD_RATE = 115200,       // Configurable baud rates
    parameter int FIFO_DEPTH = 8,           // FIFO depth (power of 2)
    parameter bit PARITY_EN = 1'b0,         // Parity enable
    parameter bit PARITY_TYPE = 1'b0        // 0=even, 1=odd parity
)(
    input  logic       clk,
    input  logic       rst_n,
    
    // Data interface
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       tx_ready,
    
    // UART output
    output logic       tx_serial,
    
    // Status signals
    output logic       tx_busy,
    output logic       fifo_full,
    output logic       fifo_empty,
    output logic       fifo_almost_full,
    output logic       fifo_almost_empty,
    output logic [$clog2(FIFO_DEPTH):0] fifo_count
);

    
    //BAUD RATE GENERATION
    
    localparam int BAUD_DIVISOR = CLK_FREQ / BAUD_RATE;
    localparam int BAUD_COUNTER_WIDTH = $clog2(BAUD_DIVISOR);
    
    logic [BAUD_COUNTER_WIDTH-1:0] baud_counter;
    logic baud_tick;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= '0;
        end else begin
            if (baud_counter == BAUD_DIVISOR - 1) begin
                baud_counter <= '0;
            end else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end
    
    assign baud_tick = (baud_counter == BAUD_DIVISOR - 1);

    
    //FIFO INSTANTIATION
    
    logic fifo_rd_en;
    logic [7:0] fifo_rd_data;
    
    sync_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(FIFO_DEPTH - 2),
        .ALMOST_EMPTY_THRESH(2)
    ) tx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(tx_valid),
        .wr_data(tx_data),
        .rd_en(fifo_rd_en),
        .rd_data(fifo_rd_data),
        .full(fifo_full),
        .empty(fifo_empty),
        .almost_full(fifo_almost_full),
        .almost_empty(fifo_almost_empty),
        .count(fifo_count)
    );
    
    // tx_ready indicates FIFO can accept new data
    assign tx_ready = !fifo_full;

    
    //UART TRANSMITTER STATE MACHINE
    
    typedef enum logic [2:0] {
        IDLE      = 3'b000,
        LOAD      = 3'b001,
        START_BIT = 3'b010,
        DATA_BITS = 3'b011,
        PARITY    = 3'b100,
        STOP_BIT  = 3'b101
    } tx_state_t;
    
    tx_state_t tx_state, tx_state_next;
    
    logic [7:0] tx_shift_reg;
    logic [2:0] bit_counter;
    logic parity_bit;
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state <= IDLE;
        end else if (baud_tick) begin
            tx_state <= tx_state_next;
        end
    end
    
    // Next state logic
    always_comb begin
        tx_state_next = tx_state;
        
        case (tx_state)
            IDLE: begin
                if (!fifo_empty) begin
                    tx_state_next = LOAD;
                end
            end
            
            LOAD: begin
                tx_state_next = START_BIT;
            end
            
            START_BIT: begin
                tx_state_next = DATA_BITS;
            end
            
            DATA_BITS: begin
                if (bit_counter == 7) begin
                    if (PARITY_EN) begin
                        tx_state_next = PARITY;
                    end else begin
                        tx_state_next = STOP_BIT;
                    end
                end
            end
            
            PARITY: begin
                tx_state_next = STOP_BIT;
            end
            
            STOP_BIT: begin
                tx_state_next = IDLE;
            end
            
            default: tx_state_next = IDLE;
        endcase
    end
    
    // Data shift register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_shift_reg <= '0;
        end else if (baud_tick) begin
            case (tx_state)
                START_BIT: begin
                    // Load data here - FIFO data is now valid after LOAD state
                    tx_shift_reg <= fifo_rd_data;
                end
                
                DATA_BITS: begin
                    tx_shift_reg <= {1'b0, tx_shift_reg[7:1]}; // Shift right, LSB first
                end
            endcase
        end
    end
    
    // Bit counter for data bits
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= '0;
        end else if (baud_tick) begin
            case (tx_state)
                START_BIT: begin
                    bit_counter <= '0;
                end
                
                DATA_BITS: begin
                    bit_counter <= bit_counter + 1;
                end
            endcase
        end
    end
    
    // Parity calculation (even/odd)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parity_bit <= '0;
        end else if (baud_tick && (tx_state == LOAD)) begin
            if (PARITY_TYPE == 1'b0) begin // Even parity
                parity_bit <= ^fifo_rd_data;  // XOR of all bits
            end else begin // Odd parity
                parity_bit <= ~(^fifo_rd_data);
            end
        end
    end
    
    // FIFO read enable - read from FIFO when going to LOAD state
    assign fifo_rd_en = baud_tick && (tx_state == IDLE) && !fifo_empty;
    
    
    // 4. OUTPUT GENERATION
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_serial <= 1'b1;  // Idle high
        end else if (baud_tick) begin
            case (tx_state)
                IDLE, LOAD: begin
                    tx_serial <= 1'b1;  // Idle state
                end
                
                START_BIT: begin
                    tx_serial <= 1'b0;  // Start bit is always 0
                end
                
                DATA_BITS: begin
                    tx_serial <= tx_shift_reg[0];  // LSB first
                end
                
                PARITY: begin
                    tx_serial <= parity_bit;
                end
                
                STOP_BIT: begin
                    tx_serial <= 1'b1;  // Stop bit is always 1
                end
                
                default: begin
                    tx_serial <= 1'b1;
                end
            endcase
        end
    end
    
    // Status signals
    assign tx_busy = (tx_state != IDLE);

endmodule


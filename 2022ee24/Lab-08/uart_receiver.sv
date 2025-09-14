module uart_receiver #(
    parameter int CLK_FREQ = 50_000_000,    // System clock frequency (50 MHz)
    parameter int BAUD_RATE = 115200,       // Baud rate (115200 bps)
    parameter int FIFO_DEPTH = 8,           // FIFO depth
    parameter bit PARITY_EN = 1,            // 1: enable parity, 0: disable
    parameter bit PARITY_ODD = 0            // 0: even parity, 1: odd parity
)(
    input  logic       clk,                 // System clock
    input  logic       rst_n,               // Active-low reset
    input  logic       rx_serial,           // Serial input line
    input  logic       rx_read,             // Read strobe from user
    output logic [7:0] rx_data,             // Received parallel data
    output logic       rx_valid,            // Data valid signal
    output logic       rx_error,            // Combined error indicator
    output logic       rx_busy,             // Receiver busy signal
    output logic       rx_frame_error,      // Stop bit error
    output logic       rx_parity_error,     // Parity error
    output logic       fifo_full,           // FIFO full status
    output logic       fifo_empty           // FIFO empty status
);

    
    // LOCAL PARAMETERS AND CALCULATIONS
    
    localparam int OVERSAMPLING = 16;                           // 16x oversampling
    localparam int BAUD_DIVIDER = CLK_FREQ / (BAUD_RATE * OVERSAMPLING);
    localparam int COUNTER_WIDTH = $clog2(BAUD_DIVIDER + 1);
    localparam int SAMPLE_COUNT_WIDTH = $clog2(OVERSAMPLING);

    
    // INTERNAL SIGNAL DECLARATIONS
    
    // Input synchronization
    logic [2:0] rx_sync;
    logic rx_clean;
    
    // Oversampling and timing
    logic [COUNTER_WIDTH-1:0] oversample_counter;
    logic [SAMPLE_COUNT_WIDTH-1:0] sample_count;
    logic sample_tick;
    logic reset_counters;
    
    // State machine
    typedef enum logic [2:0] {
        IDLE,           // Waiting for start bit
        START_BIT,      // Receiving start bit
        DATA_BITS,      // Receiving 8 data bits
        PARITY,         // Receiving parity bit (if enabled)
        STOP_BIT        // Receiving stop bit
    } state_t;
    
    state_t current_state, next_state;
    
    // Data reception
    logic [7:0] shift_reg;
    logic [3:0] bit_count;
    logic parity_bit;
    logic stop_bit_sample;
    logic calculated_parity;
    
    // FIFO interface
    logic fifo_wr_en;
    logic [8:0] fifo_wr_data;    // 8-bit data + 1-bit error flag
    logic [8:0] fifo_rd_data;
    
    // Internal error signals
    logic frame_error;
    logic parity_error;
    logic combined_error;

    
    // INPUT SYNCHRONIZATION
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync <= 3'b111;    // Initialize to idle state (high)
        end else begin
            rx_sync <= {rx_sync[1:0], rx_serial};  // 3-stage synchronizer
        end
    end
    
    assign rx_clean = rx_sync[2];  // Use synchronized signal directly

    
    // OVERSAMPLING TIMING GENERATION
    
    assign reset_counters = (current_state == IDLE) && !rx_clean;  // Reset on start bit edge
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            oversample_counter <= '0;
            sample_count <= '0;
            sample_tick <= 1'b0;
        end else if (reset_counters) begin
            // Reset counters when start bit detected
            oversample_counter <= '0;
            sample_count <= '0;
            sample_tick <= 1'b0;
        end else if (current_state != IDLE) begin
            sample_tick <= 1'b0;
            
            if (oversample_counter == BAUD_DIVIDER - 1) begin
                oversample_counter <= '0;
                
                if (sample_count == OVERSAMPLING - 1) begin
                    sample_count <= '0;
                    sample_tick <= 1'b1;  // Tick every bit period
                end else begin
                    sample_count <= sample_count + 1;
                end
            end else begin
                oversample_counter <= oversample_counter + 1;
            end
        end
    end

    
    // STATE MACHINE - STATE REGISTER
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    
    // STATE MACHINE - NEXT STATE LOGIC
    
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                // Wait for start bit (falling edge)
                if (!rx_clean) begin
                    next_state = START_BIT;
                end
            end
            
            START_BIT: begin
                // Validate start bit at middle of bit period
                if (sample_tick) begin
                    if (!rx_clean) begin
                        next_state = DATA_BITS;  // Valid start bit
                    end else begin
                        next_state = IDLE;       // False start (noise)
                    end
                end
            end
            
            DATA_BITS: begin
                // After receiving 8 data bits
                if (sample_tick && (bit_count == 7)) begin  // 0-7 = 8 bits
                    if (PARITY_EN) begin
                        next_state = PARITY;     // Go to parity if enabled
                    end else begin
                        next_state = STOP_BIT;   // Skip parity if disabled
                    end
                end
            end
            
            PARITY: begin
                // Receive parity bit
                if (sample_tick) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                // Receive stop bit and return to idle
                if (sample_tick) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    
    // DATA RECEPTION AND SHIFTING
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_count <= '0;
            parity_bit <= '0;
            stop_bit_sample <= 1'b1;
        end else begin
            case (current_state)
                IDLE: begin
                    bit_count <= '0;
                end
                
                DATA_BITS: begin
                    if (sample_tick) begin
                        // Shift right and insert new bit at MSB (LSB first transmission)
                        shift_reg <= {rx_clean, shift_reg[7:1]};
                        bit_count <= bit_count + 1;
                    end
                end
                
                PARITY: begin
                    if (sample_tick) begin
                        parity_bit <= rx_clean;
                    end
                end
                
                STOP_BIT: begin
                    if (sample_tick) begin
                        stop_bit_sample <= rx_clean;
                    end
                end
                
                default: begin
                    
                end
            endcase
        end
    end

    
    // PARITY CALCULATION
    
    always_comb begin
        if (PARITY_ODD) begin
            calculated_parity = ~^shift_reg; // Odd parity: complement of XOR
        end else begin
            calculated_parity = ^shift_reg;  // Even parity: XOR all bits
        end
    end

    
    // ERROR DETECTION AND FIFO WRITE
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_wr_en <= 1'b0;
            fifo_wr_data <= '0;
        end else begin
            fifo_wr_en <= 1'b0;  // Default
            
            // Write to FIFO when transitioning from STOP_BIT to IDLE
            if ((current_state == STOP_BIT) && (next_state == IDLE)) begin
                // Calculate errors
                frame_error = !stop_bit_sample;  // Stop bit should be high
                
                if (PARITY_EN) begin
                    parity_error = (parity_bit != calculated_parity);
                end else begin
                    parity_error = 1'b0;
                end
                
                combined_error = frame_error | parity_error;
                
                // Write to FIFO if not full
                if (!fifo_full) begin
                    fifo_wr_en <= 1'b1;
                    fifo_wr_data <= {combined_error, shift_reg};
                end
            end
        end
    end

    
    // FIFO INSTANTIATION
    
    sync_fifo #(
        .DATA_WIDTH(9),              // 8 data bits + 1 error flag
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(FIFO_DEPTH - 2),
        .ALMOST_EMPTY_THRESH(2)
    ) rx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(fifo_wr_en),
        .wr_data(fifo_wr_data),
        .rd_en(rx_read),
        .rd_data(fifo_rd_data),
        .full(fifo_full),
        .empty(fifo_empty),
        .almost_full(),
        .almost_empty(),
        .count()
    );

    
    // OUTPUT ASSIGNMENTS
    
    assign rx_data = fifo_rd_data[7:0];
    assign rx_error = fifo_rd_data[8];
    assign rx_valid = !fifo_empty;
    assign rx_busy = (current_state != IDLE);
    
    // Individual error signals (only valid when rx_error is high)
    assign rx_frame_error = rx_error ? frame_error : 1'b0;
    assign rx_parity_error = rx_error ? parity_error : 1'b0;

endmodule
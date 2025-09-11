module uart_tx_controller # (
    parameter int FIFO_DEPTH
)(
    input   logic         clk, reset_n,          // Clock and reset
    input   logic [7:0]   tx_data,               // Byte to send
    input                 data_available,        // Data present flag
    input   logic         tx_valid,              // Valid request to send
    output  logic         tx_done,               // Transmission complete
    output  logic         tx_ready,              // Ready to accept new data
    output  logic         tx_serial,             // UART serial output line
    output  logic         tx_busy,               // High when transmitting
    output  logic         frame_error            // Frame error flag
);

    // Internal signals
    logic [9:0]    shift_reg;    // Holds start bit + 8 data bits + stop bit
    logic [3:0]    bit_counter;  // Counts how many bits have been sent
    logic [11:0]   baud_counter; // Generates baud ticks
    logic          baud_tick;    // One-cycle pulse at each baud interval

    // State machine states
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        TRANSFER,
        DONE
    } state_t;

    state_t current_state, next_state;

    // Baud rate divisor (8 means 1 baud tick every 8 clk cycles here)
    logic [3:0] baud_divisor = 4'd8;

    // --------------------------
    // Baud rate generator
    // --------------------------
    // Creates baud_tick pulses whenever baud_counter reaches divisor
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (current_state != IDLE) begin
                if (baud_counter == baud_divisor - 1) begin
                    baud_counter <= 0;
                    baud_tick <= 1;  // generate one pulse
                end else begin
                    baud_counter <= baud_counter + 1;
                    baud_tick <= 0;
                end
            end else begin
                baud_counter <= 0;
                baud_tick <= 0;
            end
        end
    end

    // --------------------------
    // State register and outputs
    // --------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            shift_reg <= 10'b1111111111;  // idle line high
            bit_counter <= 0;
            tx_serial <= 1'b1;            // idle line high
            tx_done <= 0;
            tx_ready <= 1'b1;             // ready at start
            tx_busy <= 0;
            frame_error <= 1'b0;
        end else begin
            current_state <= next_state;

            // default
            tx_done <= 0;

            case (current_state) 
                // --------------------------
                // IDLE state – waiting for data
                // --------------------------
                IDLE: begin
                    tx_serial <= 1'b1; // line idle high
                    tx_ready  <= 1'b1; // ready to load new byte
                    tx_busy   <= 0;
                    bit_counter <= 0;
                end

                // --------------------------
                // LOAD state – load shift register
                // --------------------------
                LOAD: begin
                    if (baud_tick) begin 
                        // Start bit (0), 8 data bits, Stop bit (1)
                        shift_reg <= {1'b1, tx_data, 1'b0}; 
                    end
                    tx_ready <= 0;
                    tx_busy  <= 1;
                end

                // --------------------------
                // TRANSFER state – shift bits out
                // --------------------------
                TRANSFER: begin
                    tx_busy  <= 1;
                    tx_ready <= 0;
                    if (baud_tick) begin
                        // Send MSB of shift_reg first
                        tx_serial <= shift_reg[9];
                        // Shift left, fill with 1 to maintain stop bits
                        shift_reg <= {shift_reg[8:0],1'b1};
                    
                        // Count bits sent
                        if (bit_counter == 10) begin
                            bit_counter <= 0;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end

                    // Detect if frame ended improperly
                    if (( bit_counter == 10) && (tx_serial != 1))
                        frame_error <= 1'b1;
                end

                // --------------------------
                // DONE state – transmission finished
                // --------------------------
                DONE: begin
                    if (baud_tick) begin
                        tx_serial <= 1'b1; // idle line
                        tx_done   <= 1;    // flag one-cycle done pulse
                        if (data_available && tx_valid) begin
                            // more data ready to send immediately
                            tx_ready <= 0;
                            tx_busy  <= 1;
                        end else begin
                            tx_ready <= 1;
                            tx_busy  <= 0;
                        end
                    end
                end
                
                default: begin
                    tx_serial <= 1'b1;
                    tx_ready  <= 1'b1;
                    tx_busy   <= 0;
                end
            endcase
        end
    end 

    // --------------------------
    // Next state logic
    // --------------------------
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            // Wait until data available and valid
            IDLE: begin
                if (data_available && tx_valid)
                    next_state = LOAD;
            end

            // Move to TRANSFER once shift register loaded
            LOAD: begin
                if (baud_tick)
                    next_state = TRANSFER;
            end

            // Keep sending bits until all 10 bits done
            TRANSFER: begin
                if (baud_tick && (bit_counter == 10))
                    next_state = DONE;
                else
                    next_state = TRANSFER;
            end

            // After DONE either go to LOAD (if more data) or back to IDLE
            DONE: begin
                if (baud_tick) begin
                    if (data_available && tx_valid)
                        next_state = LOAD;
                    else
                        next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end
endmodule


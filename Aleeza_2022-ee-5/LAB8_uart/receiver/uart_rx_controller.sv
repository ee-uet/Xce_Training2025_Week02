module uart_rx_controller # (
    parameter int FIFO_DEPTH = 16
)(
    input   logic         clk,
    input   logic         reset_n,
    input   logic [9:0]   data_in,         // incoming 10-bit 
    input   logic         rx_valid,
    input   logic         data_available,
    output logic         rx_done,
    output logic         rx_ready,
    output logic         rx_busy,
    output logic         frame_error,
    output logic [7:0]   rx_data
);

    // simple internal signals
    logic [9:0]     shift_reg;
    logic [3:0]     bit_counter;
    logic [11:0]    baud_counter;
    logic           baud_tick;

    typedef enum logic [2:0] {
        IDLE,
        RECEIVE,
        LOAD,
        DONE
    } state_t;

    state_t current_state, next_state;

    logic [11:0] baud_divisor = 12'd8;
    logic [9:0]   temp_data;
    // Baud rate generator 
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            baud_counter <= 12'd0;
            baud_tick    <= 1'b0;
        end else begin
            if (current_state != IDLE) begin
                if (baud_counter == (baud_divisor - 12'd1)) begin
                    baud_counter <= 12'd0;
                    baud_tick    <= 1'b1;
                end else begin
                    baud_counter <= baud_counter + 12'd1;
                    baud_tick    <= 1'b0;
                end
            end else begin
                // idle: hold counters and ticks at zero
                baud_counter <= 12'd0;
                baud_tick    <= 1'b0;
            end
        end
    end

    // State register and sequential outputs/variables
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            shift_reg     <= 10'b1111111111;
            bit_counter   <= 4'd0;
            rx_data       <= 8'h00;
            rx_done       <= 1'b0;
            rx_ready      <= 1'b1;
            rx_busy       <= 1'b0;
            frame_error   <= 1'b0;
        end else begin
            current_state <= next_state;

            // default for single-cycle outputs
            rx_done <= 1'b0;

            case (current_state)
                IDLE: begin
                    rx_ready    <= 1'b1;
                    rx_busy     <= 1'b0;
                    bit_counter <= 4'd0;
                    temp_data <= data_in;
                    // keep shift_reg at ones (line idle high)
                end

                RECEIVE: begin
                    rx_busy <= 1'b1;
                    rx_ready <= 1'b0;

                    // On each baud tick, capture the incoming sample into shift_reg
                    if (baud_tick) begin
                        // shift left and sample the incoming serial bit
                        shift_reg  <= { shift_reg[8:0], temp_data[9] };
                        temp_data <= temp_data << 1;
                        bit_counter <= bit_counter + 4'd1;
                    end

                    // frame error detection
                    // We check stop bit after the 10th bit has been collected; use explicit equality
                    if ((bit_counter == 4'd10) && (shift_reg[0] != 1'b1)) begin
                        frame_error <= 1'b1;
                    end
                end

                LOAD: begin
                    if (baud_tick) begin
                        // bits [8:1] contain the 8 data bits (MSB first in this design)
                        rx_data <= shift_reg[8:1];
                        bit_counter <= 4'd0;
                    end
                    rx_ready <= 1'b0;
                    rx_busy  <= 1'b1;
                end

                DONE: begin
                    // Provide a 1-cycle rx_done pulse synchronized to baud_tick
                    if (baud_tick) begin
                        rx_done <= 1'b1;
                        // decide ready/busy state based on whether new data exists
                        if (rx_valid && data_available) begin
                            rx_ready <= 1'b0;
                            rx_busy  <= 1'b1;
                        end else begin
                            rx_ready <= 1'b1;
                            rx_busy  <= 1'b0;
                        end
                    end
                end

                default: begin
                    rx_ready <= 1'b1;
                    rx_busy  <= 1'b0;
                end
            endcase
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_available && rx_valid)
                    next_state = RECEIVE;
            end

            RECEIVE: begin
                // Move to LOAD after we've counted 10 baud-ticks
                if (bit_counter == 4'd10)
                    next_state = LOAD;
            end

            LOAD: begin
                // After latching data on a baud tick, go to DONE
                if (baud_tick)
                    next_state = DONE;
            end

            DONE: begin
                if (baud_tick) begin
                    if (data_available && rx_valid)
                        next_state = RECEIVE;
                    else
                        next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule


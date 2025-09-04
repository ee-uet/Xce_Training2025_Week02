`include "../Lab-07A_SyncFIFO/7A.sv"

module uart_transmitter #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 8 
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       tx_ready,
    output logic       tx_serial,
    output logic       tx_busy
);
	
    logic [7:0] rd_data;
    logic	pop_dat;
    logic 	em_flag;
    logic 	fl_flag;
    
    // Instantiate the FIFO
    sync_fifo #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(7),
        .ALMOST_EMPTY_THRESH(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(tx_valid),
        .wr_data(tx_data),
        .rd_en(pop_dat),
        .rd_data(rd_data),
        .full(fl_flag),
        .empty(em_flag),
        .almost_full(),
        .almost_empty(),
        .count()
    );	 
    
    assign tx_ready = ~fl_flag;

    // Fixed baud rate calculation - removed *16 which was incorrect
    // For proper UART timing, we need one clock per bit period
    localparam int BAUD_COUNT_MAX = CLK_FREQ / BAUD_RATE - 1;
    
    // State machine definition moved up for better readability
    typedef enum logic [2:0] { 
        IDLE      = 3'b000,
        LOAD      = 3'b001,
        START_BIT = 3'b010,
        DATA_BITS = 3'b011,
        PARITY    = 3'b100,
        STOP_BIT  = 3'b101
    } state_t;
    
    // Internal signals
    state_t curr_state, next_state;
    logic [$clog2(CLK_FREQ/BAUD_RATE):0] baud_counter;
    logic [2:0] bit_counter;
    logic [7:0] shift_register;
    logic parity_bit;
    logic baud_tick;
    logic bit_complete;

    // Baud rate generator
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            baud_counter <= 0;
        end else if (curr_state == IDLE) begin
            baud_counter <= 0;
        end else if (baud_counter == BAUD_COUNT_MAX) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end
    
    assign baud_tick = (baud_counter == BAUD_COUNT_MAX);

    // Bit counter for data bits
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            bit_counter <= 0;
        end else if (curr_state == DATA_BITS && baud_tick) begin
            bit_counter <= bit_counter + 1;
        end else if (curr_state != DATA_BITS) begin
            bit_counter <= 0;
        end
    end
    
    assign bit_complete = (bit_counter == 7) && baud_tick;

    // Data shift register and parity calculation
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            shift_register <= 8'h00;
            parity_bit <= 1'b0;
        end else if (curr_state == LOAD) begin
            shift_register <= rd_data;
            // Calculate even parity
            parity_bit <= ^rd_data;  // XOR reduction for even parity
        end else if (curr_state == DATA_BITS && baud_tick) begin
            shift_register <= {1'b0, shift_register[7:1]};  // Right shift
        end
    end

    // State machine sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            curr_state <= IDLE;
        end else begin
            curr_state <= next_state;
        end
    end

    // State machine combinational logic
    always_comb begin
        // Default values
        pop_dat	   = 0;	 
        next_state = curr_state;
        
        case (curr_state)
            IDLE: begin
                if (~em_flag) begin
                    pop_dat = 1;
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                next_state = START_BIT;
            end
            
            START_BIT: begin
                if (baud_tick) begin
                    next_state = DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                if (bit_complete) begin
                    next_state = PARITY;
                end
            end
            
            PARITY: begin
                if (baud_tick) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (baud_tick) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output assignments
    always_comb begin
        case (curr_state)
            IDLE: begin
                tx_serial = 1'b1;  // Idle high
                tx_busy   = 1'b0;  // Not busy
            end
            
            LOAD: begin
                tx_serial = 1'b1;  // Still high during load
                tx_busy   = 1'b1;  // Busy
            end
            
            START_BIT: begin
                tx_serial = 1'b0;  // Start bit is low
                tx_busy   = 1'b1;
            end
            
            DATA_BITS: begin
                tx_serial = shift_register[0];  // LSB first
                tx_busy   = 1'b1;
            end
            
            PARITY: begin
                tx_serial = parity_bit;
                tx_busy   = 1'b1;
            end
            
            STOP_BIT: begin
                tx_serial = 1'b1;  // Stop bit is high
                tx_busy   = 1'b1;
            end
            
            default: begin
                tx_serial = 1'b1;
                tx_busy   = 1'b0;
            end
        endcase
    end

endmodule

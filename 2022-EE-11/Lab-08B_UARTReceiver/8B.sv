`include "../Lab-07A_SyncFIFO/7A.sv"

module uart_receiver #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 16 
)(
    input  logic       		clk,
    input  logic       		rst_n,
    input  logic		rx_serial,
    
    
    output logic       		rx_valid,
    input logic			rx_ready,
    output logic		rx_error,
    output logic [7:0]       	rx_data
);

    logic [7:0] 	rx_reg;
    logic		val_frm;
    logic 		em_flag;
    logic 		fl_flag;
    
    // Instantiate the FIFO
    sync_fifo #(
    	.DATA_WIDTH(8),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(14),
        .ALMOST_EMPTY_THRESH(2)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(val_frm),
        .wr_data(rx_reg),
        .rd_en(rx_ready),
        .rd_data(rx_data),
        .full(fl_flag),
        .empty(em_flag),
        .almost_full(),
        .almost_empty(),
        .count()
    );		
	
    assign rx_valid = ~em_flag;	

    // Fixed baud rate calculation - removed *16 which was incorrect
    // For proper UART timing, we need one clock per bit period
    localparam int BAUD_COUNT_MAX = CLK_FREQ / BAUD_RATE - 1;
    
    // State machine definition - LOAD state removed for receiver
    typedef enum logic [2:0] { 
        IDLE      = 3'b000,
        START_BIT = 3'b001,
        DATA_BITS = 3'b010,
        PARITY    = 3'b011,
        STOP_BIT  = 3'b100
    } state_t;
    
    // Internal signals
    state_t curr_state, next_state;
    logic [$clog2(CLK_FREQ/BAUD_RATE):0] baud_counter;
    logic [2:0] bit_counter;
    logic [7:0] shift_register;
    logic parity_bit;
    logic received_parity;
    logic baud_tick;
    logic baud_half_tick;
    logic bit_complete;

    // Baud rate generator
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            baud_counter <= 0;
        end else if (curr_state == IDLE) begin
            baud_counter <= 0;
        end else if (baud_half_tick | baud_tick) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end
    
    assign baud_tick = (baud_counter == BAUD_COUNT_MAX) ? 1 : 0;
    assign baud_half_tick = (curr_state == START_BIT) ? (baud_counter == BAUD_COUNT_MAX/2) : 0;

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

    // Data shift register - samples at baud_tick (middle of bit period)
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            shift_register <= 8'h00;
        end else if (curr_state == DATA_BITS && baud_tick) begin
            shift_register <= {rx_serial, shift_register[7:1]};  // Right shift, MSB first
        end
    end

    // Parity bit sampling - separate register as requested
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            received_parity <= 1'b0;
        end else if (curr_state == PARITY && baud_tick) begin
            received_parity <= rx_serial;
        end
    end

    // Calculate expected parity for verification
    assign parity_bit = ^shift_register;  // Even parity

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
        next_state = curr_state;
        
        case (curr_state)
            IDLE: begin
                if (~rx_serial) begin  // Start bit detected (falling edge)
                    next_state = START_BIT;
                end
            end
                        
            START_BIT: begin
                if (baud_half_tick) begin  // Sample at middle of start bit
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
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rx_reg <= 8'h00;
            rx_error <= 1'b0;
        end else if (curr_state == STOP_BIT && baud_tick) begin
            // Data is valid when we complete stop bit and parity is correct
            val_frm <= (rx_serial == 1'b1) && (received_parity == parity_bit);
            rx_error <= (rx_serial == 1'b0) | (received_parity != parity_bit);
            rx_reg <= shift_register;
        end else begin
            rx_error <= 1'b0;
            val_frm <= 1'b0;
        end
    end

endmodule

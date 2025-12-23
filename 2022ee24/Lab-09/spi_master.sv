module spi_master #(
    parameter int NUM_SLAVES = 4,
    parameter int DATA_WIDTH = 8
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [DATA_WIDTH-1:0]     tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                      start_transfer,
    input  logic                      cpol,
    input  logic                      cpha,
    input  logic [15:0]              clk_div,
    
    output logic [DATA_WIDTH-1:0]     rx_data,
    output logic                      transfer_done,
    output logic                      busy,
    
    // SPI interface
    output logic                      spi_clk,
    output logic                      spi_mosi,
    input  logic                      spi_miso,
    output logic [NUM_SLAVES-1:0]     spi_cs_n
);

    // --- Internal Register Definitions ---
    logic [DATA_WIDTH:0] shift_reg;      // Main shift register     size is datawidth + 1
    logic [15:0] clk_counter;              // Counter for generating SPI clock
    logic [$clog2(DATA_WIDTH):0] bit_counter; // Counts bits transferred
    logic spi_clk_edge;                    // Pulse indicating when to act on SPI clock edges

    // --- State Machine Definitions ---
    // We now have 6 distinct states as initially discussed
    typedef enum logic [2:0] {
        IDLE,
        MODE0,
        MODE1,
        MODE2,
        MODE3,
        DONE
    } state_t;
    
    state_t state, next_state;

    // --- State Register (Synchronous Update) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // --- Next State Logic (Combinational) ---
    always_comb begin
        next_state = state; // Default: stay in current state
        unique case (state)
            IDLE: begin
                if (start_transfer) begin
                    // Decode the CPOL/CPHA inputs to choose the correct mode state
                    unique case ({cpol, cpha})
                        2'b00: next_state = MODE0;
                        2'b01: next_state = MODE1;
                        2'b10: next_state = MODE2;
                        2'b11: next_state = MODE3;
                    endcase
                end
            end

            MODE0, MODE1, MODE2, MODE3: begin
                // Stay in the current mode state until all bits are transferred
                if (bit_counter == (DATA_WIDTH)) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                next_state = IDLE; // Always return to IDLE after DONE
            end

            default: next_state = IDLE;
        endcase
    end

    // --- SPI Clock Generation (Same for all modes) ---
    assign spi_clk_edge = (clk_counter == 0);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
            spi_clk <= 1'b0;
        end else begin 
            if (state == MODE0 || state == MODE1 || state == MODE2 || state == MODE3) begin // Active in any mode state
                if (clk_counter == 0) begin
                    clk_counter <= clk_div/2;
                    spi_clk <= ~spi_clk; // Toggle SPI clock
                end else begin
                    clk_counter <= clk_counter - 1;
                end
            end else begin
                // Not in an active mode, hold SPI clock at its idle value
                clk_counter <= clk_div;
                // Set idle state based on *current* mode (for clean exit) or default (CPOL=0)
                spi_clk <= cpol;  
            end
        end
    end

    // --- Shift Register, Bit Counter, and Data Logic ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_counter <= '0;
            spi_mosi <= 1'b0;
            rx_data <= '0;
            transfer_done <= 1'b0;
        end else begin
            transfer_done <= 1'b0;

            case (state)
                IDLE: begin
                    bit_counter <= '0;
                    if (start_transfer) begin
                        shift_reg <= {tx_data,1'b0};
                    end
                    spi_mosi <= tx_data[DATA_WIDTH-1];
                end

                MODE0: begin
                    if (spi_clk_edge) begin
                        if (spi_clk == 1'b0) begin // Leading Edge (Rising, but currently LOW)
                            // CPHA=0: Sample on Leading Edge (prepare to sample on next posedge of spi_clk)
                            // Shift in MISO on the system clock *before* spi_clk rises
                            shift_reg <= {shift_reg[DATA_WIDTH-1:0], spi_miso};
                        end else begin // Trailing Edge (Falling, currently HIGH)
                            // CPHA=0: Change on Trailing Edge
                            spi_mosi <= shift_reg[DATA_WIDTH];
                            shift_reg <= {shift_reg[DATA_WIDTH-1],shift_reg[DATA_WIDTH-1:0]};
                            bit_counter <= bit_counter + 1; // Count on trailing edge for MODE0
                        end
                    end
                end

                MODE1: begin
                    if (spi_clk_edge) begin
                        if (spi_clk == 1'b0) begin // Leading Edge (Rising, but currently LOW)
                            // CPHA=1: Change on Leading Edge
                            spi_mosi <= shift_reg[DATA_WIDTH];
                            shift_reg <= {shift_reg[DATA_WIDTH-1],shift_reg[DATA_WIDTH-1:0]};
                        end else begin // Trailing Edge (Falling, currently HIGH)
                            // CPHA=1: Sample on Trailing Edge
                            shift_reg <= {shift_reg[DATA_WIDTH-1:0], spi_miso};
                            bit_counter <= bit_counter + 1; // Count on trailing edge for MODE1
                        end
                    end
                end

                MODE2: begin
                    if (spi_clk_edge) begin
                        if (spi_clk == 1'b1) begin // Leading Edge (Falling, but currently HIGH)
                            // CPHA=0: Sample on Leading Edge
                            shift_reg <= {shift_reg[DATA_WIDTH-1:0], spi_miso};
                        end else begin // Trailing Edge (Rising, currently LOW)
                            // CPHA=0: Change on Trailing Edge
                            spi_mosi <= shift_reg[DATA_WIDTH];
                            shift_reg <= {shift_reg[DATA_WIDTH-1],shift_reg[DATA_WIDTH-1:0]};
                            bit_counter <= bit_counter + 1; // Count on trailing edge for MODE2
                        end
                    end
                end

                MODE3: begin
                    if (spi_clk_edge) begin
                        if (spi_clk == 1'b1) begin // Leading Edge (Falling, but currently HIGH)
                            // CPHA=1: Change on Leading Edge
                            spi_mosi <= shift_reg[DATA_WIDTH];
                            shift_reg <= {shift_reg[DATA_WIDTH-1],shift_reg[DATA_WIDTH-1:0]};
                        end else begin // Trailing Edge (Rising, currently LOW)
                            // CPHA=1: Sample on Trailing Edge
                            shift_reg <= {shift_reg[DATA_WIDTH-1:0], spi_miso};
                            bit_counter <= bit_counter + 1; // Count on trailing edge for MODE3
                        end
                    end
                end

                DONE: begin
                    rx_data <= shift_reg[DATA_WIDTH-1:0];
                    transfer_done <= 1'b1;
                end
            endcase
        end
    end

    // --- Slave Select (Chip Select) Logic ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_cs_n <= '1;
        end else begin
            if (state == IDLE && start_transfer) begin
                spi_cs_n <= ~(1 << slave_sel);
            end else if (state == DONE) begin
                spi_cs_n <= '1;
            end
            // Hold the selected value throughout all MODE states
        end
    end

    // --- Busy Signal Output ---
    assign busy = (state != IDLE);

endmodule
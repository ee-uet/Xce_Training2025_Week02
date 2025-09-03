module spi_master #(
    parameter int NUM_SLAVES = 4,
    parameter int DATA_WIDTH = 8,
    // small CS timing (in system-clock cycles) to satisfy tSS_setup / tSS_hold
    parameter int CS_SETUP_CYCLES = 1,
    parameter int CS_HOLD_CYCLES  = 1
)(
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic [DATA_WIDTH-1:0]     tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                      start_transfer, // pulse (1-cycle) to start
    input  logic                      cpol,
    input  logic                      cpha,
    input  logic [15:0]               clk_div,       // half-period in sys clk cycles (min 1)
    
    output logic [DATA_WIDTH-1:0]     rx_data,
    output logic                      transfer_done,
    output logic                      busy,
    
    // SPI interface (physical pins)
    output logic                      spi_clk,
    output logic                      spi_mosi,
    input  logic                      spi_miso,
    output logic [NUM_SLAVES-1:0]     spi_cs_n
);

    //-------------------------------------------------------------------------
    // Local types / states
    //-------------------------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE,
        ASSERT_CS,
        TRANSFER,
        DEASSERT_CS,
        DONE_STATE
    } state_t;

    state_t state, next_state;

    //-------------------------------------------------------------------------
    // Internal registers
    //-------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] tx_shift;
    logic [DATA_WIDTH-1:0] rx_shift;
    logic [$clog2(DATA_WIDTH):0] bit_cnt; // enough bits to count DATA_WIDTH down
    logic [$clog2(NUM_SLAVES)-1:0] sel_reg;

    // clock generation
    logic [15:0] div_cnt;
    logic spi_clk_reg;
    logic spi_clk_prev;
    logic running; // enable toggling of spi_clk_reg

    // cs timing counters
    logic [$clog2(CS_SETUP_CYCLES+1)-1:0] cs_setup_cnt;
    logic [$clog2(CS_HOLD_CYCLES+1)-1:0]  cs_hold_cnt;

    // outputs initialization
    assign spi_clk = spi_clk_reg;

    // default CS high (inactive)
    // We'll drive only the selected CS during transfer; others remain high.
    // Reset sets all CS to 1
    // Note: active low CS
    always_comb begin
        spi_cs_n = {NUM_SLAVES{1'b1}};
        if (state == ASSERT_CS || state == TRANSFER || state == DEASSERT_CS) begin
            spi_cs_n[sel_reg] = 1'b0;
        end
    end

    //-------------------------------------------------------------------------
    // Clock divider / SCK generation (no gating of sys clk)
    // spi_clk_reg toggles only when running == 1
    // spi_clk_reg idle value equals CPOL
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt      <= 16'd1;
            spi_clk_reg  <= cpol;
            spi_clk_prev <= cpol;
        end else begin
            spi_clk_prev <= spi_clk_reg;
            if (running) begin
                // ensure clk_div min 1 -> half-period at least 1 sys clk
                if (clk_div <= 16'd1) begin
                    // toggle every sys clk edge
                    spi_clk_reg <= ~spi_clk_reg;
                    div_cnt <= 16'd1;
                end else begin
                    if (div_cnt == 0) begin
                        spi_clk_reg <= ~spi_clk_reg;
                        div_cnt <= clk_div - 1;
                    end else begin
                        div_cnt <= div_cnt - 1;
                    end
                end
            end else begin
                // not running: hold SCK at idle level (CPOL)
                spi_clk_reg <= cpol;
                div_cnt <= (clk_div <= 1) ? 16'd1 : clk_div - 1;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Edge detection in system clock domain
    //-------------------------------------------------------------------------
    wire rising_edge_sck  = (spi_clk_prev == 1'b0) && (spi_clk_reg == 1'b1);
    wire falling_edge_sck = (spi_clk_prev == 1'b1) && (spi_clk_reg == 1'b0);
    wire is_leading_edge  = (cpol == 1'b0) ? rising_edge_sck : falling_edge_sck;
    wire is_trailing_edge = ~is_leading_edge;
    wire sample_edge      = (cpha == 1'b0) ? is_leading_edge : is_trailing_edge;
    wire shift_edge       = ~sample_edge;

    //-------------------------------------------------------------------------
    // FSM: control flow and shift/sample behavior
    //-------------------------------------------------------------------------
    // next_state logic (simple synchronous state machine)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start_transfer)
                    next_state = ASSERT_CS;
            end
            ASSERT_CS: begin
                // after cs_setup cycles, go to TRANSFER
                if (cs_setup_cnt == 0)
                    next_state = TRANSFER;
            end
            TRANSFER: begin
                // when last bit sampled, move to DEASSERT_CS
                if ((bit_cnt == 0) && sample_edge)
                    next_state = DEASSERT_CS;
            end
            DEASSERT_CS: begin
                if (cs_hold_cnt == 0)
                    next_state = DONE_STATE;
            end
            DONE_STATE: begin
                // one cycle to let outputs settle; then IDLE
                next_state = IDLE;
            end
        endcase
    end

    //-------------------------------------------------------------------------
    // Main sequential logic: counters, shifts, flags
    //-------------------------------------------------------------------------
    // Defaults
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy          <= 1'b0;
            transfer_done <= 1'b0;
            running       <= 1'b0;
            sel_reg       <= '0;
            tx_shift      <= '0;
            rx_shift      <= '0;
            bit_cnt       <= '0;
            cs_setup_cnt  <= '0;
            cs_hold_cnt   <= '0;
            spi_mosi      <= 1'b0;
            rx_data       <= '0;
        end else begin
            transfer_done <= 1'b0; // default clear; assert when done state processed

            case (state)
                IDLE: begin
                    busy    <= 1'b0;
                    running <= 1'b0;
                    // wait for start_transfer pulse (edge-triggered external)
                    if (start_transfer) begin
                        busy     <= 1'b1;
                        sel_reg  <= slave_sel;
                        tx_shift <= tx_data;
                        rx_shift <= '0;
                        // initialize bit counter to DATA_WIDTH (we decrement on sample)
                        bit_cnt <= DATA_WIDTH;
                        // prepare MOSI for CPHA=0: MOSI must be valid before first leading edge
                        // present MSB on MOSI now (safe even for CPHA=1)
                        spi_mosi <= tx_data[DATA_WIDTH-1];
                        // CS setup counter
                        cs_setup_cnt <= (CS_SETUP_CYCLES > 0) ? CS_SETUP_CYCLES - 1 : 0;
                    end
                end

                ASSERT_CS: begin
                    busy <= 1'b1;
                    // hold spi_mosi as prepared in IDLE (or user may have changed)
                    // when cs_setup_cnt reaches zero, next_state will go TRANSFER and running becomes 1
                    if (cs_setup_cnt != 0)
                        cs_setup_cnt <= cs_setup_cnt - 1;
                end

                TRANSFER: begin
                    busy <= 1'b1;
                    // enable SCK toggling
                    running <= 1'b1;

                    // SHIFT edge: when shift_edge==1, update tx_shift / present next MOSI bit
                    if (shift_edge) begin
                        // shift tx_shift left by 1, fill LSB with 0 (or don't care)
                        // present next bit on MOSI (MSB-first)
                        // For the very first shift edge in CPHA=1 mode, this will shift out the first bit.
                        tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
                        spi_mosi <= tx_shift[DATA_WIDTH-1];
                    end

                    // SAMPLE edge: capture MISO into rx_shift
                    if (sample_edge) begin
                        // push sampled bit to LSB side (MSB-first capture)
                        rx_shift <= {rx_shift[DATA_WIDTH-2:0], spi_miso};
                        if (bit_cnt != 0)
                            bit_cnt <= bit_cnt - 1;
                        // If bit_cnt becomes 0 here, FSM will move to DEASSERT_CS
                        // We keep running=1 until DEASSERT_CS to ensure clock stops gracefully.
                    end
                end

                DEASSERT_CS: begin
                    // stop clock toggling and keep CS asserted for cs_hold_cycles
                    running <= 1'b0;
                    if (cs_hold_cnt == 0) begin
                        cs_hold_cnt <= (CS_HOLD_CYCLES > 0) ? CS_HOLD_CYCLES - 1 : 0;
                    end else begin
                        cs_hold_cnt <= cs_hold_cnt - 1;
                    end
                    // latch final rx data for the user
                    rx_data <= rx_shift;
                end

                DONE_STATE: begin
                    // finalize
                    busy <= 1'b0;
                    running <= 1'b0;
                    transfer_done <= 1'b1;
                    // keep MOSI at last value or set to 0 (we leave it unchanged)
                end

                default: begin
                    // shouldn't happen
                    busy <= 1'b0;  
                    running <= 1'b0;
                end
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Small note:
    // - For CPHA==0 we ensured MOSI had the MSB loaded before the first leading edge
    //   by preparing spi_mosi in IDLE when start_transfer was seen.
    // - For CPHA==1 the first shift happens on the first leading edge, and sample on trailing.
    // - If you want LSB-first behavior, invert the shift logic appropriately.
    //-------------------------------------------------------------------------

endmodule


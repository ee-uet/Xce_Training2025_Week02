module spi_master #(
    parameter int NUM_SLAVES = 4,
    parameter int DATA_WIDTH = 8
)(
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic [DATA_WIDTH-1:0]         tx_data,
    input  logic [$clog2(NUM_SLAVES)-1:0] slave_sel,
    input  logic                          start_transfer,
    input  logic                          cpol,
    input  logic                          cpha,
    input  logic [15:0]                   clk_div,
    output logic [DATA_WIDTH-1:0]         rx_data,
    output logic                          transfer_done,
    output logic                          busy,

    output logic                          spi_clk,
    output logic                          spi_mosi,
    input  logic                          spi_miso,
    output logic [NUM_SLAVES-1:0]         spi_cs_n
);

    // Internal signals
    logic [15:0] clk_counter;
    logic        spi_clk_int, spi_clk_prev;
    logic        spi_rise, spi_fall;
    logic        shift_pulse, sample_pulse;
    logic        shift_pulse_d, sample_pulse_d;
    logic [DATA_WIDTH-1:0] rx_shift_reg, tx_shift_reg;
    logic [$clog2(DATA_WIDTH):0] bit_count;
    logic                        cs_active;

    // SPI clock generation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
            spi_clk_int <= cpol;
        end else if (busy) begin
            if (clk_counter == clk_div) begin
                clk_counter <= 0;
                spi_clk_int <= ~spi_clk_int;
            end else
                clk_counter <= clk_counter + 1;
        end else begin
            clk_counter <= 0;
            spi_clk_int <= cpol;
        end
    end
    assign spi_clk = spi_clk_int;

    // Edge detection
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            spi_clk_prev <= cpol;
        else
            spi_clk_prev <= spi_clk_int;
    end
    assign spi_rise = (spi_clk_int && !spi_clk_prev);
    assign spi_fall = (!spi_clk_int && spi_clk_prev);

    // Generate shift/sample pulses based on CPOL/CPHA
    always_comb begin
        case ({cpol, cpha})
            2'b00: begin sample_pulse = spi_rise; shift_pulse = spi_fall; end
            2'b01: begin shift_pulse  = spi_rise; sample_pulse = spi_fall; end
            2'b10: begin sample_pulse = spi_fall; shift_pulse  = spi_rise; end
            2'b11: begin shift_pulse  = spi_fall; sample_pulse = spi_rise; end
            default: begin shift_pulse = 0; sample_pulse = 0; end
        endcase
    end


    // Main FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy          <= 0;
            transfer_done <= 0;
            spi_cs_n      <= {NUM_SLAVES{1'b1}};
            spi_mosi      <= 0;
            tx_shift_reg  <= 0;
            rx_shift_reg  <= 0;
            rx_data       <= 0;
            bit_count     <= 0;
            cs_active     <= 0;
        end else begin
            transfer_done <= 0;

            // Start transfer
            if (start_transfer && !busy) begin
                busy         <= 1;
                cs_active    <= 1;
                spi_cs_n     <= {NUM_SLAVES{1'b1}};
                spi_cs_n[slave_sel] <= 0;
                tx_shift_reg <= tx_data;
                rx_shift_reg <= 0;
                bit_count    <= DATA_WIDTH;

                // Preload MOSI for CPHA=0
                if (!cpha)
                    spi_mosi <= tx_data[DATA_WIDTH-1];
                else
                    spi_mosi <= 0;
            end

            // Shift out MOSI on shift pulse
            if (busy && shift_pulse && bit_count > 0) begin
              if (!cpha) begin
                spi_mosi <= tx_shift_reg[DATA_WIDTH-2];                   
                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};    // shift left
            end
              else begin
                spi_mosi <= tx_shift_reg[DATA_WIDTH-1];                   // output MSB
                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};    // shift left
              end
            end
            // Sample MISO on sample pulse
            if (busy && sample_pulse && bit_count > 0) begin
                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], spi_miso};
                bit_count <= bit_count - 1;

                if (bit_count == 1) begin
                    rx_data       <= {rx_shift_reg[DATA_WIDTH-2:0], spi_miso};
                    busy          <= 0;
                    transfer_done <= 1;
                    spi_cs_n      <= {NUM_SLAVES{1'b1}};
                    cs_active     <= 0;
                    spi_mosi      <= 0;
                end
            end

            // Reset CS if inactive
            if (!cs_active)
                spi_cs_n <= {NUM_SLAVES{1'b1}};
        end
    end

endmodule

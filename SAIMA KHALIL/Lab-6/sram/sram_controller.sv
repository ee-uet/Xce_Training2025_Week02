module sram_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n, 
    output logic        sram_we_n
);

    logic [15:0] read_data_reg;    //storing sram read value temp
    logic [15:0] sram_data_out;   // data driven to SRAM bus
    logic        sram_data_oe;    // 1 = drive, 0 = release

    assign sram_data   = sram_data_oe ? sram_data_out : 16'bz;
    assign read_data = read_data_reg;
 

    typedef enum logic [1:0] {
        IDLE,
        WRITE,
        READ
    } state_t;

    state_t state, next_state;
 
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (write_req) next_state = WRITE;
                else if (read_req) next_state = READ;
            end
            WRITE:     next_state = IDLE;
            READ:      next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            ready         <= 1'b0;
            sram_ce_n     <= 1'b1;
            sram_we_n     <= 1'b1;
            sram_oe_n     <= 1'b1;
            sram_data_out <= 16'h0000;
            sram_data_oe  <= 1'b0;
            read_data_reg <= 16'h0000;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    ready        <= 1'b0;
                    sram_ce_n    <= 1'b1;
                    sram_we_n    <= 1'b1;
                    sram_oe_n    <= 1'b1;
                    sram_data_oe <= 1'b0; // release bus

                    if (write_req) begin
                        sram_addr    <= address;
                        sram_data_out<= write_data;
                        sram_data_oe <= 1'b1;   // drive bus 
                        sram_ce_n    <= 1'b0;
                        sram_we_n    <= 1'b0;   // active low write
                    end 
                    else if (read_req) begin
                        sram_addr    <= address;
                        sram_ce_n    <= 1'b0;
                        sram_oe_n    <= 1'b0;   // start read
                        sram_data_oe <= 1'b0;   // release bus
                    end
                end

                WRITE: begin
                    sram_we_n    <= 1'b1;   // finish write
                    sram_ce_n    <= 1'b1;
                    sram_data_oe <= 1'b0;   // release bus
                    ready        <= 1'b1;   // write done
                end

                READ: begin
                    read_data_reg <= sram_data; // capture SRAM output
                    ready         <= 1'b1;         // data valid
                    sram_oe_n     <= 1'b1;         // disable OE
                    sram_ce_n     <= 1'b1;
                end
 
            endcase
        end
    end


endmodule

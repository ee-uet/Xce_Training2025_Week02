module axi4_lite_master (

    // Local interface for CPU/testbench
    input  logic        write_req,
    input  logic [31:0] write_address,
    input  logic [31:0] write_data,
    input  logic [3:0]  write_strb,
    output logic        write_done,
    output logic [1:0]  write_response,

    input  logic        read_req,
    input  logic [31:0] read_address,
    output logic        read_done,
    output logic [31:0] read_data,
    output logic [1:0]  read_response,

    axi4_lite_if.master  axi_if
);

    // FSM types
    typedef enum logic [1:0] {
        W_IDLE, W_ADDR, W_DATA, W_RESP
    } write_state_t;

    typedef enum logic [1:0] {
        R_IDLE, R_ADDR, R_DATA
    } read_state_t;

    write_state_t write_state;
    read_state_t  read_state;

    always_ff @(posedge axi_if.clk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            write_state                  <= W_IDLE;
            axi_if.write_address          <= 32'h0;
            axi_if.write_address_valid    <= 1'b0;
            axi_if.write_data             <= 32'h0;
            axi_if.write_strb             <= 4'h0;
            axi_if.write_data_valid       <= 1'b0;
            axi_if.write_response_ready   <= 1'b0;
            write_done                    <= 1'b0;
            write_response                <= 2'b00;
        end else begin
            write_done <= 1'b0;

            case (write_state)
                W_IDLE: begin
                    axi_if.write_address_valid  <= 1'b0;
                    axi_if.write_data_valid     <= 1'b0;
                    axi_if.write_response_ready <= 1'b0;

                    if (write_req) begin
                        axi_if.write_address       <= write_address;
                        axi_if.write_address_valid <= 1'b1;
                        axi_if.write_data          <= write_data;
                        axi_if.write_strb          <= write_strb;
                        axi_if.write_data_valid    <= 1'b1;
                        write_state                <= W_ADDR;
                    end
                end

                W_ADDR: begin
                    if (axi_if.write_address_valid && axi_if.write_address_ready) begin
                        axi_if.write_address_valid <= 1'b0;
                        write_state                <= W_DATA;
                    end
                end

                W_DATA: begin
                    if (axi_if.write_data_valid && axi_if.write_data_ready) begin
                        axi_if.write_data_valid     <= 1'b0;
                        axi_if.write_response_ready <= 1'b1;
                        write_state                 <= W_RESP;
                    end
                end

                W_RESP: begin
                    if (axi_if.write_response_valid) begin
                        write_response               <= axi_if.write_response;
                        write_done                   <= 1'b1;
                        axi_if.write_response_ready  <= 1'b0;
                        write_state                  <= W_IDLE;
                    end
                end

                default: write_state <= W_IDLE;
            endcase
        end
    end

    always_ff @(posedge axi_if.clk or negedge axi_if.rst_n) begin
        if (!axi_if.rst_n) begin
            read_state                 <= R_IDLE;
            axi_if.read_address        <= 32'h0;
            axi_if.read_address_valid  <= 1'b0;
            axi_if.read_data_ready     <= 1'b0;
            read_done                  <= 1'b0;
            read_data                  <= 32'h0;
            read_response              <= 2'b00;
        end else begin
            read_done <= 1'b0;

            case (read_state)
                R_IDLE: begin
                    axi_if.read_address_valid <= 1'b0;
                    axi_if.read_data_ready    <= 1'b0;

                    if (read_req) begin
                        axi_if.read_address       <= read_address;
                        axi_if.read_address_valid <= 1'b1;
                        read_state                <= R_ADDR;
                    end
                end

                R_ADDR: begin
                    if (axi_if.read_address_valid && axi_if.read_address_ready) begin
                        axi_if.read_address_valid <= 1'b0;
                        axi_if.read_data_ready    <= 1'b1;
                        read_state                <= R_DATA;
                    end
                end

                R_DATA: begin
                    if (axi_if.read_data_valid && axi_if.read_data_ready) begin
                        read_data     <= axi_if.read_data;
                        read_response <= axi_if.read_response;
                        read_done     <= 1'b1;
                        axi_if.read_data_ready <= 1'b0;
                        read_state    <= R_IDLE;
                    end
                end

                default: read_state <= R_IDLE;
            endcase
        end
    end

endmodule

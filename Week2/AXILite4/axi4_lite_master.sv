module axi4lite_master (

    // -------------------------------------------------------
    // Local interface for CPU / Testbench
    // -------------------------------------------------------
    input  logic        wr_req,
    input  logic [31:0] wr_addr,
    input  logic [31:0] wr_data_in,
    input  logic [3:0]  wr_strb_in,
    output logic        wr_done,
    output logic [1:0]  wr_resp_out,

    input  logic        rd_req,
    input  logic [31:0] rd_addr,
    output logic        rd_done,
    output logic [31:0] rd_data_out,
    output logic [1:0]  rd_resp_out,

    // AXI4-Lite Interface
    axi4lite_if.master axi
);

    // -------------------------------------------------------
    // FSM Types
    // -------------------------------------------------------
    typedef enum logic [1:0] {W_IDLE, W_ADDR, W_DATA, W_RESP} wr_state_t;
    typedef enum logic [1:0] {R_IDLE, R_ADDR, R_DATA}         rd_state_t;

    wr_state_t wr_state;
    rd_state_t rd_state;

    // -------------------------------------------------------
    // Write FSM
    // -------------------------------------------------------
    always_ff @(posedge axi.clk or negedge axi.rst_n) begin
        if (!axi.rst_n) begin
            wr_state        <= W_IDLE;
            axi.wr_addr     <= '0;
            axi.wr_addr_vld <= 1'b0;
            axi.wr_data     <= '0;
            axi.wr_strb     <= '0;
            axi.wr_data_vld <= 1'b0;
            axi.wr_resp_rdy <= 1'b0;
            wr_done         <= 1'b0;
            wr_resp_out     <= '0;
        end else begin
            wr_done <= 1'b0; // default

            case (wr_state)
                W_IDLE: begin
                    axi.wr_addr_vld <= 1'b0;
                    axi.wr_data_vld <= 1'b0;
                    axi.wr_resp_rdy <= 1'b0;

                    if (wr_req) begin
                        axi.wr_addr     <= wr_addr;
                        axi.wr_addr_vld <= 1'b1;

                        axi.wr_data     <= wr_data_in;
                        axi.wr_strb     <= wr_strb_in;

                        wr_state <= W_ADDR;
                    end
                end

                W_ADDR: if (axi.wr_addr_vld && axi.wr_addr_rdy) begin
                    axi.wr_addr_vld <= 1'b0;
                    axi.wr_data_vld <= 1'b1;
                    wr_state        <= W_DATA;
                end

                W_DATA: if (axi.wr_data_vld && axi.wr_data_rdy) begin
                    axi.wr_data_vld <= 1'b0;
                    axi.wr_resp_rdy <= 1'b1;
                    wr_state        <= W_RESP;
                end

                W_RESP: if (axi.wr_resp_vld) begin
                    wr_resp_out     <= axi.wr_resp;
                    wr_done         <= 1'b1;
                    axi.wr_resp_rdy <= 1'b0;
                    wr_state        <= W_IDLE;
                end

                default: wr_state <= W_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------
    // Read FSM
    // -------------------------------------------------------
    always_ff @(posedge axi.clk or negedge axi.rst_n) begin
        if (!axi.rst_n) begin
            rd_state        <= R_IDLE;
            axi.rd_addr     <= '0;
            axi.rd_addr_vld <= 1'b0;
            axi.rd_data_rdy <= 1'b0;
            rd_done         <= 1'b0;
            rd_data_out     <= '0;
            rd_resp_out     <= '0;
        end else begin
            rd_done <= 1'b0; // default

            case (rd_state)
                R_IDLE: begin
                    axi.rd_addr_vld <= 1'b0;
                    axi.rd_data_rdy <= 1'b0;

                    if (rd_req) begin
                        axi.rd_addr     <= rd_addr;
                        axi.rd_addr_vld <= 1'b1;
                        rd_state        <= R_ADDR;
                    end
                end

                R_ADDR: if (axi.rd_addr_vld && axi.rd_addr_rdy) begin
                    axi.rd_addr_vld <= 1'b0;
                    axi.rd_data_rdy <= 1'b1;
                    rd_state        <= R_DATA;
                end

                R_DATA: if (axi.rd_data_vld && axi.rd_data_rdy) begin
                    rd_data_out     <= axi.rd_data;
                    rd_resp_out     <= axi.rd_resp;
                    rd_done         <= 1'b1;
                    axi.rd_data_rdy <= 1'b0;
                    rd_state        <= R_IDLE;
                end

                default: rd_state <= R_IDLE;
            endcase
        end
    end

endmodule

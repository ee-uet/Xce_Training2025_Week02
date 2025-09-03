typedef enum logic [3:0] {
    PWR_UP = 4'b0000,
    PRE_CHARGE = 4'b0001,
    REFRESH = 4'b0010,
    IDLE = 4'b0011,
    ACTIVE_READ = 4'b0100,
    READ_DELAY = 4'b0101,
    READ = 4'b0110,
    ACTIVE_WRITE = 4'b0111,
    WRITE = 4'b1000,
} state_t;

module fsm_ddr (
    input logic clk,
    input logic rst_n,
    input logic cpu_wr, cpu_rd,
    input logic [3:0] in_ddr_bank,
    input logic [15:0] in_ddr_row,
    input logic [7:0] in_ddr_col,
    input logic [31:0] ddr_read_data,
    inout logic [31:0] cpu_data,
    input logic count_done,
    output logic count_start,
    output logic [4:0] count_value,
    output logic [31:0] ddr_write_data,
    output logic ready, pwr_up, pre_chrage, refresh, active, ddr_read, ddr_write,
    output logic [3:0] out_ddr_bank,
    output logic [15:0] out_ddr_row,
    output logic [7:0] out_ddr_col,
);
endmodule
state_t c_state, n_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state <= PWR_UP;
    end else begin
        c_state <= n_state;
    end
end
//next state logic
always_comb begin
    case (n_state) 
        PWR_UP: begin
            if (count_done) begin
                n_state = PRE_CHARGE;
            end else begin
                n_state = PWR_UP;
            end
        end
        PRE_CHARGE: begin
            if (count_done) begin
                n_state = REFRESH;
            end else begin
                n_state = PRE_CHARGE;
            end
        end
        REFRESH: begin
            if (count_done) begin
                n_state = IDLE;
            end else begin
                n_state = REFRESH;
            end
        end
        IDLE: begin
            if (cpu_rd) begin
                n_state = ACTIVE_READ;
            end else if (cpu_wr) begin
                n_state = ACTIVE_WRITE;
            end else begin
                n_state = IDLE;
            end
        end
        ACTIVE_READ: begin
            if (count_done) begin
                n_state = READ_DELAY;
            end else begin
                n_state = ACTIVE_READ;
            end
        end
        READ_DELAY: begin
            if (count_done) begin
                n_state = READ;
            end else begin
                n_state = READ_DELAY;
            end
        end
        READ: begin
            n_state = IDLE;
        end
        ACTIVE_WRITE: begin
            if (count_done) begin
                n_state = WRITE;
            end else begin
                n_state = ACTIVE_WRITE;
            end
        end
        WRITE: begin 
            if (count_done) begin
                n_state = IDLE;
            end else begin
                n_state = WRITE;
            end
            
        end

    endcase
end
//output logic
always_comb begin
    ready = 1'b0;
    pwr_up = 1'b0;
    pre_chrage = 1'b0;
    refresh = 1'b0;
    active = 1'b0;
    ddr_read = 1'b0;
    ddr_write = 1'b0;
    out_ddr_bank = 4'b0000;
    out_ddr_row = 16'd0;
    out_ddr_col = 8'd0;
    ddr_write_data = 32'd0;
    count_start = 1'b0;
    count_value = 5'd0;
    case (n_state)
        PWR_UP: begin
            pwr_up = 1'b1;
            count_start = 1'b1;
            count_value = 5'd15; //15 clock cycles delay
        end
        PRE_CHARGE: begin
            pre_chrage = 1'b1;
            count_start = 1'b1;
            count_value = 5'd10; //10 clock cycles 10*10ns = 100ns delay
        end
        REFRESH: begin
            refresh = 1'b1;
            count_start = 1'b1;
            count_value = 5'd7; //7 clock cycles 7*10ns = 70ns delay
        end
        IDLE: begin
            ready = 1'b1;
        end
        ACTIVE_READ: begin
            active = 1'b1;
            out_ddr_bank = in_ddr_bank;
            out_ddr_row = in_ddr_row;
            count_start = 1'b1;
            count_value = 5'd3; //3 clock cycles 3*10ns = 30ns delay
        end
        READ_DELAY: begin
            count_start = 1'b1;
            count_value = 5'd5; //5 clock cycles 2*10ns = 50ns delay
            out_ddr_col = in_ddr_col;
            ddr_read = 1'b1;
        end
        READ: begin
            cpu_data = ddr_read_data;
        end
        ACTIVE_WRITE: begin
            active = 1'b1;
            out_ddr_bank = in_ddr_bank;
            out_ddr_row = in_ddr_row;
            count_start = 1'b1;
            count_value = 5'd3; //3 clock cycles 3*10ns = 30ns delay
        end
        WRITE: begin
            out_ddr_col = in_ddr_col;
            ddr_write = 1'b1;
            ddr_write_data = cpu_data;
            count_start = 1'b1;
            count_value = 5'd5; //5 clock cycles 2*10ns =
            
        end


    endcase
end

    



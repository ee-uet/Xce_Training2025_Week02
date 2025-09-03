/* Implementaion of DDR Controller */
module top_module (
    input logic clk,
    input logic rst_n,
    input logic cpu_wr, cpu_rd,
    input logic [31:0] cpu_addr,
    inout logic [31:0] cpu_data,
    input logic [31:0] ddr_read_data,
    output logic ready, pwr_up, pre_chrage, refresh, active, ddr_read, ddr_write,
    output logic [31:0] ddr_write_data,
    output logic [3:0] out_ddr_bank,
    output logic [15:0] out_ddr_row,
    output logic [7:0] out_ddr_col
    
);
logic count_start, count_done;
logic [4:0] count_value;
logic [3:0] in_ddr_bank;
logic [15:0] in_ddr_row;
logic [7:0] in_ddr_col;
timer down_timer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .count_start(count_start),
    .count_value(count_value),
    .count_done(count_done)
);
address_logic addr_logic_inst (
    .cpu_addr(cpu_addr),
    .in_ddr_bank(in_ddr_bank),
    .in_ddr_row(in_ddr_row),
    .in_ddr_col(in_ddr_col)
);
fsm_ddr fsm_ddr_inst (
    .clk(clk),
    .rst_n(rst_n),
    .cpu_wr(cpu_wr),
    .cpu_rd(cpu_rd),
    .in_ddr_bank(in_ddr_bank),
    .in_ddr_row(in_ddr_row),
    .in_ddr_col(in_ddr_col),
    .ddr_read_data(ddr_read_data),
    .cpu_data(cpu_data),
    .count_done(count_done),
    .count_start(count_start),
    .count_value(count_value),
    .ddr_write_data(ddr_write_data),
    .ready(ready),
    .pwr_up(pwr_up),
    .pre_chrage(pre_chrage),
    .refresh(refresh),
    .active(active),
    .ddr_read(ddr_read),
    .ddr_write(ddr_write),
    .out_ddr_bank(out_ddr_bank),
    .out_ddr_row(out_ddr_row),
    .out_ddr_col(out_ddr_col)
);
    
endmodule
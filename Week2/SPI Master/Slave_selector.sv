/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : Slave_selector.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : Slave selector by using the active low method, Here bit 0 means the slave 0 and bit 1 means slave 1 in spi_cs_n
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module Slave_selector #(parameter int NUM_SLAVES = 4) (
    input   logic                              clk,
    input   logic                              rst_n,
    input   logic                              start_transfer,
    input   logic [$clog2(NUM_SLAVES) - 1 : 0] slave_sel,
    output  logic [      (NUM_SLAVES) - 1 : 0] spi_cs_n
);

    always_ff @( posedge clk or negedge rst_n ) begin : Slave_sel_spi

        if (!rst_n) begin
            spi_cs_n                <=   '1;             // Reset to no slave
        end
        else if (start_transfer) begin
            spi_cs_n                <=    '1;            // Creating SPI_cs_n
            spi_cs_n [slave_sel]    <=   1'b0;           // Active low that bit to selecte that slave (MSB side)
        end
        else begin
            spi_cs_n                <=   '1;            // Assigning 1 to all bits first for no slave selection
        end

    end

endmodule
/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : SPI_flag_controller.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : SPI_flags generation is done in this program where transfer done and busy signal are produced using Counter module's count and enable is done
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module SPI_flag_controller #(parameter int DATA_WIDTH = 8) (
    input   logic [DATA_WIDTH - 1 : 0] count,
    input   logic                      start_transfer,
    output  logic                      enable,
    output  logic                      transfer_done,
    output  logic                      busy
);
    
    assign enable           =   start_transfer;

    always_comb begin : transfer_started

            transfer_done   = 1'b0;                     // Default setting of flags
            busy            = 1'b0;

        if (count == (DATA_WIDTH - 1)) begin
            transfer_done   = 1'b1;                     // transfer_done when the counter reaches limit
            busy            = 1'b0;                     // Busy become zero when transfer done
        end
        else if (count < (DATA_WIDTH - 1)) begin
            transfer_done   = 1'b0;                     // Opposite of the case descibed above
            busy            = 1'b1;
        end

    end

endmodule
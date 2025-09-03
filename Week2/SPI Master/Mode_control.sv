/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : Mode_control.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : Set the different modes of the SPI master (0, 1, 2, 3) 
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module Mode_control (
    input   logic   CPOL,
    input   logic   CPHA,
    output  logic   clk_idle,
    output  logic   shift_edge,
    output  logic   sample_edge
);

    always_comb begin : Control_Shift_edge

            clk_idle    = CPOL;
            sample_edge = CPOL ~^ CPHA;     // XNOR to give 1 when both CPHA and CPOL are same
            shift_edge  = CPOL  ^ CPHA;     // XOR  to give 1 when both CPHA and CPOL are different
        
        end

endmodule
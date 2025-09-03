/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : Counter.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : Counts from 0 up to the maximum representable value (2^DATA_WIDTH - 1), then requires reset_n to start again.
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module Counter #(parameter int DATA_WIDTH = 8) (
    input   logic                      clk,
    input   logic                      rst_n,
    input   logic                      enable,
    output  logic [DATA_WIDTH - 1 : 0] count
);

            logic [DATA_WIDTH - 1 : 0] next_count;       //next count logic

    always_comb begin :                                 next_count_logic

        if (enable) begin
            if (count == {DATA_WIDTH{1'b1}}) begin      // stop at all 1s (max value)
                next_count  = count;
            end
            else begin
                next_count      = count + 1;            // Increment by one    
            end               
        end
        else begin
            next_count      = count;                    // Prevent from latching
        end

    end
    always_ff @( posedge clk or negedge rst_n ) begin : Reg_8_bit

        if (!rst_n) begin
            count           <= '0;                    // Negative edge of rst will reset the counter to 0
        end
        else if (enable) begin
            count           <= next_count;              // Connect the next count logic 
        end 

    end

endmodule
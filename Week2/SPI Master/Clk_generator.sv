/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : Clk_generator.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : Clk_generator that generates a custom clk for SPI (Sclk) by dividing the input clk 
                   with the given 16 bit clk_div and using the clk_idle
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module Clk_generator (
    input   logic           clk,
    input   logic           rst_n,
    input   logic           clk_idle,
    input   logic           start_transfer,
    input   logic   [15: 0] clk_div,
    output  logic           Sclk
);

            logic   [15: 0] counter;                        // Counter same as width of clk_div
            logic           Sclk_mid;                       // Countinusly generate the clk using the comparater logic

    always_ff @( posedge clk or negedge rst_n ) begin : Clk_Dividing_Reg

        if (!rst_n) begin                                   // Reset the counter and clk
            counter         <=  '0;                         // '0 will get the same number of bits as assigned by the default couter logic
            Sclk_mid        <=  clk_idle;
        end
        else begin
            if (counter == (clk_div)/2 - 1) begin           // Dividing the clk
                Sclk_mid    <=  ~Sclk_mid;                  // Toggle the bit 
                counter     <=  '0;                         // Again initiating the counter
            end
            else begin
                counter     <=  counter + 1;                // Increment the counter
            end
        end

    end

    always_comb begin :                                 Custom_Clk_Out
        
        if (start_transfer) begin
            Sclk            =   Sclk_mid;                   
        end
        else begin
            Sclk            =   clk_idle;                   // Idle clk when no data transfer or receive is required
        end

    end

endmodule
/*-----------------------------------------------------------------------------
 *  Project      : SPI master
 *  File Name    : SPI_datapath.sv
 *  Author       : Naqi Ul Hassan
 *  Date Created : 2025-08-31
 *  Description  : Shift or data, data transfer and data receive is done using shift registers and output rx_data is produced along with spi_mosi.
                   Here, LSB comes first and MSB later.
 *
 *  Revision History:
 *  Date        Author          Description
 *  ----------  --------------  ---------------------------------------------
 *  2025-08-31  Naqi Ul Hassan  Initial version
 *-----------------------------------------------------------------------------
 */

module SPI_datapath #(parameter int DATA_WIDTH = 8) (
    input   logic                      clk,
    input   logic                      rst_n,
    input   logic                      busy,
    input   logic                      transfer_done,
    input   logic                      start_transfer,
    input   logic                      sample_edge,
    input   logic                      shift_edge,
    input   logic [DATA_WIDTH - 1 : 0] tx_data,
    input   logic                      spi_miso,
    output  logic                      spi_mosi,
    output  logic [DATA_WIDTH - 1 : 0] rx_data
);

            logic [DATA_WIDTH - 1 : 0] shift_reg_mosi, shift_reg_miso;                      // Shift registers for MISO and MOSI operations

    generate
        if (sample_edge) && (!shift_edge) begin
            assign  spi_mosi                        =   shift_reg_mosi[0];                          // Assigned spi_mosi the first bit to be transfered

            always_ff @( posedge  clk or negedge rst_n ) begin :    Transfer_data
                
                if (!rst_n) begin
                    shift_reg_mosi                  <=  '0;                                         // Shift_reg_mosi reset to all 0 
                end
                else if (start_transfer) begin
                    shift_reg_mosi                  <=  tx_data;                                    // Assigning data in parallel to all bits of shift_reg_mosi
                end
                else if (busy && shift_edge) begin
                    shift_reg_mosi                  <=  shift_reg_mosi >> 1;                        // Bit shift right at every posedge clk
                end

            end

            always_ff @( negedge clk or  negedge rst_n ) begin :    Receive_data
                
                if (!rst_n) begin
                    shift_reg_miso                  <=  '0;                                         // Shift_reg_mosi reset to all 0
                end
                else if (busy && sample_edge) begin
                    shift_reg_miso                  <= {spi_miso, shift_reg_miso[DATA_WIDTH-1:1]};  // Assigned spi_miso to the MSB of the shift_reg_miso and bit shift right at every posedge clk
                end

            end

            always_comb begin :                                     Data_received

                if (transfer_done) begin
                    rx_data                         <= shift_reg_miso;                              // Output rx_data when transfer done
                end
                else begin
                    rx_data                         <= '0;
                end

            end
        end
    endgenerate

    generate
        if (!sample_edge) && (shift_edge) begin
            assign  spi_mosi                        =   shift_reg_mosi[0];                          // Assigned spi_mosi the first bit to be transfered

            always_ff @( negedge  clk or negedge rst_n ) begin :    Transfer_data
                
                if (!rst_n) begin
                    shift_reg_mosi                  <=  '0;                                         // Shift_reg_mosi reset to all 0 
                end
                else if (start_transfer) begin
                    shift_reg_mosi                  <=  tx_data;                                    // Assigning data in parallel to all bits of shift_reg_mosi
                end
                else if (busy && shift_edge) begin
                    shift_reg_mosi                  <=  shift_reg_mosi >> 1;                        // Bit shift right at every posedge clk
                end

            end

            always_ff @( posedge clk or  negedge rst_n ) begin :    Receive_data
                
                if (!rst_n) begin
                    shift_reg_miso                  <=  '0;                                         // Shift_reg_mosi reset to all 0
                end
                else if (busy && sample_edge) begin
                    shift_reg_miso                  <= {spi_miso, shift_reg_miso[DATA_WIDTH-1:1]};  // Assigned spi_miso to the MSB of the shift_reg_miso and bit shift right at every posedge clk
                end

            end

            always_comb begin :                                     Data_received

                if (transfer_done) begin
                    rx_data                         <= shift_reg_miso;                              // Output rx_data when transfer done
                end
                else begin
                    rx_data                         <= '0;
                end

            end
        end
    endgenerate 

endmodule
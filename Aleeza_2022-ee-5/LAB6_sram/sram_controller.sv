module sram_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        read_req,
    input  logic        write_req,
    input  logic [14:0] address,
    input  logic [15:0] write_data,
    output logic [15:0] read_data,
    output logic        ready,

    // SRAM interface
    output logic [14:0] sram_addr,
    inout  wire  [15:0] sram_data,
    output logic        sram_ce_n,
    output logic        sram_oe_n,
    output logic        sram_we_n
);

    // Internal tri-state control
    logic [15:0] data_out;
    logic        drive_bus;  //1:write, 0:read

    // Assign address always
    assign sram_addr = address;

    assign sram_data = (drive_bus) ? data_out : 16'bz;

    // Read data capture
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 16'b0;
        end else if (read_req) begin
            // Latch incoming data from SRAM
            read_data <= sram_data;
        end
    end

    // Control signals + bus drive
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sram_ce_n <= 1'b1;
            sram_oe_n <= 1'b1;
            sram_we_n <= 1'b1;
            data_out  <= 16'b0;
            drive_bus <= 1'b0;
            ready     <= 1'b0;
        end else begin
            ready <= 1'b0; // default

            if (write_req) begin
                // --- Write Cycle ---
                sram_ce_n <= 1'b0;
                sram_we_n <= 1'b0; //active low
                sram_oe_n <= 1'b1; //active low
                data_out  <= write_data;
                drive_bus <= 1'b1;
                ready     <= 1'b1;

            end else if (read_req) begin
                // --- Read Cycle ---
                sram_ce_n <= 1'b0;
                sram_we_n <= 1'b1;
                sram_oe_n <= 1'b0;
                drive_bus <= 1'b0;
                ready     <= 1'b1;

            end else begin
                // --- Idle ---
                sram_ce_n <= 1'b1;
                sram_we_n <= 1'b1;
                sram_oe_n <= 1'b1;
                drive_bus <= 1'b0;
                ready     <= 1'b0;
            end
        end
    end

endmodule


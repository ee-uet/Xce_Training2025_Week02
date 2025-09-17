interface axi4_lite_if (
    input logic clk,
    input logic rst_n
);

    // Write Address Channel
    logic [31:0] write_address;
    logic        write_address_valid;
    logic        write_address_ready;

    // Write Data Channel
    logic [31:0] write_data;
    logic [3:0]  write_strb;
    logic        write_data_valid;
    logic        write_data_ready;

    // Write Response Channel
    logic [1:0]  write_response;
    logic        write_response_valid;
    logic        write_response_ready;

    // Read Address Channel
    logic [31:0] read_address;
    logic        read_address_valid;
    logic        read_address_ready;

    // Read Data Channel
    logic [31:0] read_data;
    logic [1:0]  read_response;
    logic        read_data_valid;
    logic        read_data_ready;

    // Modports
    modport master (
        output write_address, write_address_valid,
               write_data, write_strb, write_data_valid, write_response_ready,
               read_address, read_address_valid, read_data_ready,
        input  write_address_ready, write_data_ready, write_response, write_response_valid,
               read_address_ready, read_data, read_response, read_data_valid,
        input  clk, rst_n
    );

    modport slave (
        input  write_address, write_address_valid,
               write_data, write_strb, write_data_valid, write_response_ready,
               read_address, read_address_valid, read_data_ready,
        output write_address_ready, write_data_ready, write_response, write_response_valid,
               read_address_ready, read_data, read_response, read_data_valid,
        input  clk, rst_n
    );

endinterface

interface axi_uart_intf (
    
);

    logic [7:0] tx_data;
    logic       tx_valid;
    logic       tx_ready;
    logic       tx_ack;
    logic [31:0] tx_baud_rate;


    logic [7:0] rx_data;
    logic       rx_ready;
    logic       frame_error;
    logic [31:0] rx_baud_rate;

    modport uart_tx (
    
        input  tx_baud_rate,
        input  tx_data,
        input  tx_valid,
        output tx_ready,
        output tx_ack
    );
    modport axi_slave (

        input tx_ready,
        input tx_ack,
        output tx_baud_rate,
        output tx_data,
        output tx_valid,

        input rx_ready, frame_error,
        input rx_data,
        output rx_baud_rate
        
    );
    modport uart_rx (
        input  rx_baud_rate,
        output rx_data,
        output rx_ready,
        output frame_error

    );


endinterface
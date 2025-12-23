package pkg;
typedef enum logic [2:0] {
    ADD=3'h0,
    SUB=3'h1,
    AND=3'h2,
    OR =3'h3,
    XOR=3'h4,
    NOT=3'h5,
    SLL=3'h6,
    SRL=3'h7
} operation;

typedef enum logic{
    SHIFT =1'b0,
    ROTATE=1'b1
} mode;

typedef enum logic{
    LEFT  =1'b0,
    RIGHT =1'b1
} direction;

typedef struct packed {
    logic [3:0]nible_1;
    logic [3:0]nible_2;
    logic [3:0]nible_3;
    logic [7:0]binary_in;
} bcd;

typedef enum logic[2:0] { 
    NS_GREEN_EW_RED,
    NS_YELLOW_EW_RED,
    NS_RED_EW_GREEN,
    NS_RED_EW_YELLOW,
    EMERGENCY_ALL_RED,
    PEDESTRIAN_CROSSING,
    STARTUP_FLASH
} traffic;
typedef enum logic [1:0] { 
    RED,
    GREEN,
    YELLOW
 } traffic_lights;

typedef enum logic [2:0] {
    C_0,
    C_5,
    C_10,
    C_15,
    C_20,
    C_25
 } coins;

typedef enum logic[5:0] {         
    COIN_0= 6'b111110,
    COIN_5= 6'b111101,
    COIN_10=6'b111011,
    COIN_15=6'b110111,
    COIN_20=6'b101111,
    COIN_25=6'b011111, 
    ERROR  =6'b111111 
} display;

typedef enum logic [1:0] { 
    OFF=2'b00,
    ONE_SHORT=2'b01,
    PERIODIC=2'b10,
    PWM=2'b11
 } timer_mode;

 typedef enum logic [2:0] { 
    IDEAL,
    LOAD,
    START_BIT,
    DATA_BITS,
    PARITY,
    STOP_BIT
 } uart_transmit;

typedef enum logic [2:0] { 
    RX_IDEAL,
    RX_START_BIT,
    RX_DATA_BITS,
    RX_PARITY,
    RX_STOP_BIT
} uart_receive;

typedef struct packed {
    logic parity_bit;
    logic stop_bit;
} uart_status_reg_en;

typedef enum logic [1:0] { 
    INITIAL, 
    READ, 
    WRITE, 
    DONE 
} sram_state;

typedef enum logic [1:0] { 
IDLE,
SETUP, 
TRANSFER, 
COMPLETE 
} spi_state;

// State machines for read and write channels
typedef enum logic [1:0] {
W_IDLE, 
W_ADDR, 
W_DATA, 
W_RESP
} write_state_t;
typedef enum logic [1:0] {
R_IDLE, 
R_ADDR, 
R_DATA
} read_state_t;
endpackage



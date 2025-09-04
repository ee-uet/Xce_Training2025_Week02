//When the processor reads data, the first 8 bits are data bits. and the 9th one is ready status signal.
//When the processor writes data, the first S-1 bits are the slave no. , next 8 bits are data bits. then the next 18 bits : first 16 is clk_divisor, 17th is cpol, 18th is cpha.
module SPI_Core 
    #(parameter sl = 4, 
                t_setup = 512,
                t_hold = 512, 
                t_turn = 1024) 
(
    input logic             clk,
    input logic             reset,

    input logic             write,          // Write instruction.
    input logic             cpol_i,             
    input logic             cpha_i,
    input logic             spi_miso,
    input logic [1:0]       instr,          //I use this to first write the slave no. and the data bits, then I write the control bits(dvsr, cpol, cpha)
    input logic [sl-1:0]    ss_n,
    input logic [7:0]       data_reg,
    input logic [15:0]      dvsr_in,

    output logic            spi_done,
    output logic            spi_sclk,       //This is used to synchronize with other chips(slaves).
    output logic            spi_mosi,
    output logic [7:0]      out_reg,        //This is fetched from the SPI after transmission.
    output logic [sl-1:0]   spi_ss_n        //The slave Selector.(01, 10). 11 being the null value. (Slaves are active-low.)
);

logic           wr_en, wr_ss, 
                wr_spi, wr_ctrl;

logic [sl-1:0]  ss_n_reg;
logic           ss_en;

logic [7:0]     spi_out;

logic           spi_ready,
                cpol, cpha;
logic [15:0]    dvsr;

SPI SPI_Controller(
    .clk(clk), 
    .rst(reset),
    .Din(data_reg[7:0]),
    .dvsr(dvsr),
    .start(wr_spi),
    .cpol(cpol),
    .cpha(cpha),
    .ss_h_cycle(t_hold),
    .ss_t_cycle(t_turn),
    .ss_s_cycle(t_setup),
    .Dout(spi_out),
    .sclk(spi_sclk),
    .miso(spi_miso),
    .mosi(spi_mosi),
    .spi_done_tick(),
    .ready(spi_ready),
    .ss_n_out(ss_en)
);

always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin
        cpol        <= 1'b0;
        cpha        <= 1'b0;
        dvsr        <= 15'h200;         // Hexadecimal equivalent of 512.
        ss_n_reg    <= {sl{1'b1}};      // Repeats 1 "sl" times.
    end
    else begin

        if (wr_ctrl) begin
            dvsr    <= dvsr_in[15:0];
            cpol    <= cpol_i;
            cpha    <= cpha_i;
        end

        if(wr_ss) ss_n_reg  <= ss_n[sl-1:0];    
    end
end

assign wr_en    = write;                                // First the Write instruction.
assign wr_ss    = wr_en && (instr[1:0] == 2'b01);       // Writing the Slave no.(The first S bits are now gone.)
assign wr_spi   = wr_en && (instr[1:0] == 2'b10);       // Writing to SPI.(Then the data bits.)
assign wr_ctrl  = wr_en && (instr[1:0] == 2'b11);       // Writing to Control Register.(Then the remaining 18 bits.)

// Further partitioning of the Control register.
// Using buffer to write Slave no.

assign spi_ss_n = ss_n_reg | {sl{ss_en}};               // When ss_en goes to 0, then we just do bitwise OR and see which line/path is equal to 0.

//The read data register.
assign out_reg  = spi_out;
assign spi_done = spi_ready;

endmodule

module SPI (
    input logic         clk, rst,

    input logic         start, cpha, 
                        cpol, miso,

    input logic [7:0]   Din,

    input logic [15:0]  ss_s_cycle,
                        ss_h_cycle,
                        ss_t_cycle,  
                        dvsr,
    
    
    output logic [7:0]  Dout,

    output logic        sclk, spi_done_tick, 
                        ready, mosi, ss_n_out
);

typedef enum {  Idle , 
                ss_setup , 
                cpha_delay , 
                ss_hold , 
                ss_turn , 
                p0 ,
                p1 
                } state;

state           stt_reg, stt_next;

logic [15:0]    c_reg, c_next;

logic [7:0]     si_reg, si_next,
                so_reg, so_next;

logic [2:0]     n_reg, n_next;  // I count based on two modes, 
                                // If phase is 0, then I increase at the middle of bit , 
                                // Else I count at the Loading of bit.

logic           ready_i, spi_done_tick_i,
                sclk_reg, sclk_next,
                pclk;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        stt_reg     <= Idle;
        c_reg       <= 0;
        n_reg       <= 0;
        si_reg      <= 0;
        so_reg      <= 0;
        sclk_reg    <= 1'b0;
    end
    else begin
        stt_reg     <= stt_next;
        c_reg       <= c_next;
        n_reg       <= n_next;
        si_reg      <= si_next;
        so_reg      <= so_next;
        sclk_reg    <= sclk_next;
    end
end

always_comb begin 
    spi_done_tick_i     = 1'b0;
    ready_i             = 1'b0;
    
    c_next              = c_reg;
    n_next              = n_reg;
    si_next             = si_reg;
    so_next             = so_reg;
    stt_next            = stt_reg;
    
    case (stt_reg)
        
        Idle: begin
            ready_i         = 1'b1;

            if (start) begin
                c_next      = 0;
                n_next      = 0;
                stt_next    = ss_setup;    
            end
        end

        ss_setup: begin
            if (c_reg == ss_s_cycle) begin
                so_next     = Din;
                ss_n_out    = 1'b0;
                c_next      = 0;
                stt_next    = p0;
            end
            else c_next     = c_next + 1;
        end            

        p0: begin //s_clk 0-to-1
            if (c_reg == dvsr) begin
                si_next     = {si_next[6:0], miso}; 
                c_next      = 0;
                stt_next    = p1;
            end
            else begin
                c_next      = c_next + 1; 
            end
        end
        
        p1: begin //s_clk 1-to-0
            if(c_reg == dvsr) begin
                if (n_reg == 7) begin
                    stt_next    = ss_hold;
                end    
                else begin
                    so_next     = {so_next[6:0], 1'b0};
                    c_next      = 0;
                    n_next      = n_next + 1;
                    stt_next    = p0;
                end
            end else begin
                c_next      = c_next + 1;
            end
        end
        
        ss_hold: begin
            if (c_reg == ss_h_cycle) begin
                    spi_done_tick_i = 1'b1;
                    c_next          = 0;
                    stt_next        = ss_turn;
                end
            else c_next             = c_next + 1;        
        end
       
        ss_turn: begin
            ss_n_out = 1'b1;
            if (c_reg == ss_t_cycle) stt_next = Idle;
            else c_next = c_next + 1;
        end         
    endcase
end

assign spi_done_tick    = spi_done_tick_i;
assign ready            = ready_i;

//When state is p1, then at cpha = 0, we get 1, else 0, and the reverse for state = p0.
assign pclk         = (stt_next == p1 && ~cpha) || (stt_next == p0 && cpha); //I assume here that cpol is 0 by default.

assign sclk_next    = (cpol) ? ~pclk : pclk; //This inverts the clk based on polarity.

assign Dout = si_reg;
assign mosi = so_reg[0];
assign sclk = sclk_reg;  

endmodule

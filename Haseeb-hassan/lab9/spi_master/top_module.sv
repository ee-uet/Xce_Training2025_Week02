
module top_module (
    input  logic        clk,            
    input  logic        rst_n,        
    input  logic        start_transfer, 
    input  logic [7:0]  tx_data,       
    input  logic [1:0]  slave_sel,      
    input  logic [15:0] clk_div,        
    input  logic        cpol,           
    input  logic        cpha,          
    output logic        spi_clk,       
    output logic        mosi,       
    input  logic        miso,       
    output logic [3:0]  spi_cs_n,      // Chip select for slaves (active low)
    output logic        busy,           
    output logic        transfer_done,
    output logic [7:0]  rx_data
);
    logic        load_en;
    logic        smple_en_posedge;
    logic        smple_en_negedge;
    logic        shift_en_negedge;
    logic        shift_en_posedge;
    logic        done;
    logic        count_done;
    logic        start_count;
    logic        start_clk;
    logic        mosi_posedge;
    logic        mosi_negedge;
    logic        rx_data_posedge;
    logic        rx_data_negedge;
    logic        count_2;
    
    // Instantiate the FSM
    fsm_spi fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start_transfer(start_transfer),
        .count_done(count_done),
        .cpol(cpol),
        .cpha(cpha),
        .sample_en_posedge(smple_en_posedge),
        .sample_en_negedge(smple_en_negedge),
        .shift_en_negedge(shift_en_negedge),
        .shift_en_posedge(shift_en_posedge),
        .start_count(start_count),
        .start_clk(start_clk),
        .busy(busy),
        .transfer_done(transfer_done),
        .done(done),
        .load_en(load_en)
    
    );
    slave_sel slave_select_inst (
        .slave_sel(slave_sel),
        .start_count(start_count),
        .slave_out(spi_cs_n)
    );

    // Instantiate the SPI Clock Generator
    spiClk_generator clk_gen_inst (
        .clk(clk),
        .reset_n(rst_n),
        .div_val(clk_div),
        .cpol(cpol),
        .start_clk(start_clk),
        .spi_clk(spi_clk)
    );

    // Instantiate the Shift Register for MOSI (on posedge)
    shiftReg_posedge mosi_shift_reg_inst (
        .clk(clk),
        .spi_clk(spi_clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .load_en(load_en),
        .count_2(count_2),
        .mosi(mosi_posedge),
        .shift_en_posedge(shift_en_posedge)
    );
    shiftReg_negedge mosi_shift_reg_negedge_inst (
        .clk(clk),
        .spi_clk(spi_clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .load_en(load_en),
        .count_2(count_2),
        .mosi(mosi_negedge),
        .shift_en_negedge(shift_en_negedge)
    );

    // Instantiate the Shift Register for MISO (on negedge)
    smpleReg_negedge miso_shift_reg_inst (
        .spi_clk(spi_clk),
        .rst_n(rst_n),
        .smple_en_negedge(smple_en_negedge),
        .miso(miso),
        .done(done),
        .rx_data(rx_data_negedge)
    );
    smpleReg_posedge miso_shift_reg_posedge_inst (
        .spi_clk(spi_clk),
        .rst_n(rst_n),
        .smple_en_posedge(smple_en_posedge),
        .miso(miso),
        .done(done),
        .rx_data(rx_data_posedge)
    );

    // Instantiate the Counter
    counter count_inst (
        .spi_clk(spi_clk),
        .rst_n(rst_n),
        .start_count(start_count), 
        .count_done(count_done),
        .count_2(count_2)
    );

    always_comb begin 
        if (shift_en_posedge) begin
            mosi = mosi_posedge;
        end else if (shift_en_negedge) begin
            mosi = mosi_negedge;
        end else begin
            mosi = 1'b0; // Default value when not shifting
        end
        
    
    end
    always_comb begin 
        if (smple_en_posedge) begin
            rx_data = rx_data_posedge;
        end else if (smple_en_negedge) begin
            rx_data = rx_data_negedge;
        end else begin
            rx_data = 8'b0; // Default value when not sampling
        end
        
    
    end


endmodule
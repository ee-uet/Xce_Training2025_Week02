module fsm_spi (
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          start_transfer,
    input  logic                          cpol,
    input  logic                          cpha,
    input  logic                          count_done,

    output logic                          busy,
    output logic                          load_en,
    output logic                          shift_en_posedge,
    output logic                          shift_en_negedge,
    output logic                          sample_en_posedge,
    output logic                          sample_en_negedge,
    output logic                          transfer_done,
    output logic                          start_count,
    output logic                          start_clk,
    output logic                          done,
    output logic latch_data_en 
);

   
    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        TRANSFER,
        FINISH
    } state_t;

    state_t c_state, n_state;

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            c_state <= IDLE;
        else
            c_state <= n_state;
    end

    
    always_comb begin
        
        case (c_state)
            IDLE: begin
                if (start_transfer) begin
                    n_state = LOAD;
                end
                else begin
                    n_state = IDLE;
                end
            end

            LOAD: begin
                n_state = TRANSFER;
            end

            TRANSFER: begin
                if (count_done) begin
                    n_state = FINISH;
                end
                else begin
                    n_state = TRANSFER;
                end
            end
            FINISH: begin
                n_state = IDLE;
            end
            default : n_state = IDLE;
        endcase
    end

    
    always_comb begin
        // defaults
        busy              = 1'b0;
        load_en           = 1'b0;
        shift_en_posedge  = 1'b0;
        shift_en_negedge  = 1'b0;
        sample_en_posedge = 1'b0;
        sample_en_negedge = 1'b0;
        transfer_done     = 1'b0;
        start_count       = 1'b0;
        start_clk         = 1'b0;
        done              = 1'b0;
        latch_data_en = 1'b0;

        case (c_state)
            IDLE: begin
                transfer_done = 1'b1;
            end

            LOAD: begin
                
                load_en = 1'b1;     // Load data into shift register
                busy    = 1'b1;              
            end
            
            TRANSFER: begin
                busy        = 1'b1;
                start_count = 1'b1;  
                start_clk   = 1'b1;
                latch_data_en = 1'b1;
                case ({cpol, cpha})
                    2'b00: begin
                        shift_en_negedge  = 1'b1; // Shift on falling edge
                        sample_en_posedge = 1'b1; // Sample on rising edge
                    end
                    2'b01: begin
                        shift_en_posedge  = 1'b1; // Shift on rising edge
                        sample_en_negedge = 1'b1; // Sample on falling edge
                    end
                    2'b10: begin
                        shift_en_posedge  = 1'b1; // Shift on rising edge
                        sample_en_negedge = 1'b1; // Sample on falling edge
                    end
                    2'b11: begin
                        shift_en_negedge  = 1'b1; // Shift on falling edge
                        sample_en_posedge = 1'b1; // Sample on rising edge
                    end
                endcase
            end


            FINISH: begin
                busy = 1'b1;
                done = 1'b1;
            end
        endcase
    end

endmodule
// End of file
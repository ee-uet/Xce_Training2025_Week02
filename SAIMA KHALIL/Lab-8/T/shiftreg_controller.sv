module shiftreg_controller(
    input  logic       clk,
    input  logic       rst,
    input  logic       s_empty,
    input  logic       f_rd_en,
    input  logic       baud_tick,
    input  logic [3:0] count_d,
    output logic       s_shift,
    output logic       s_load,
    output logic       done
); 
    typedef enum logic [1:0] {IDLE, LOAD, SHIFT} state_t;
    state_t cs, ns;

    // Next state logic
    always_comb begin
        ns = cs; // default
        case(cs)
            IDLE: if(f_rd_en && s_empty ) ns = LOAD;
            LOAD: if(baud_tick)ns = SHIFT;
            SHIFT: if(count_d < 10) ns = SHIFT;
                   else if(count_d == 10) ns = IDLE;
        endcase
    end 

    // Output logic
    always_comb begin
        // Defaults
        s_shift = 0;
        s_load  = 0;
        done    = 0;

        case(cs)
            IDLE: begin
                if( f_rd_en && s_empty ) begin
                    s_load  = 0;
                    done    = 0;
                    s_shift = 0;
                end
            end
            LOAD:begin
                    s_load  = 1;
                    s_shift = 0;
                    done    = 0;
            end
            SHIFT: begin
                if(count_d <= 10) begin
                    s_shift = 1;
                end
                else if(count_d > 10) begin
                    done = 1;
                    s_shift = 0;
                end
            end
        endcase
    end

    // State register
    always_ff @(posedge baud_tick or posedge rst) begin
        if(rst)
            cs <= IDLE;
        else
            cs <= ns;
    end
endmodule

module multi_mode_timer (
    input  logic        clk,         // 1 MHz clock input
    input  logic        rst_n,       // Active-low reset
    input  logic [1:0]  mode,        // 00=off, 01=one-shot, 10=periodic, 11=PWM
    input  logic [15:0] prescaler,   // Clock divider value
    input  logic [31:0] reload_val,  // Value to reload counter with
    input  logic [31:0] compare_val, // For PWM duty cycle comparison
    input  logic        start,       // Start signal to begin counting
    output logic        timeout,     // Pulse output when counter reaches 0
    output logic        pwm_out,     // PWM output signal
    output logic [31:0] current_count // Current counter value
);

    // Internal signals
    logic [15:0] prescaler_counter;      // Counter for prescaler division
    logic prescaled_clock_enable;        // Enable signal from prescaler
    logic load_counter;                  // Signal to load counter with reload_val
    logic counter_enable;                // Signal to enable counting
    
    // FSM states
    typedef enum logic {IDLE = 1'b0, RUNNING = 1'b1} state_t;
    state_t current_state, next_state;
    
    // Mode register to detect mode changes
    logic [1:0] mode_reg;
    
    // Prescaler logic: Divides 1MHz clock by (prescaler + 1)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler_counter <= 16'b0;
            prescaled_clock_enable <= 1'b0;
        end else begin
            if (prescaler == 16'b0) begin
                // If prescaler is 0, enable every clock cycle
                prescaled_clock_enable <= 1'b1;
                prescaler_counter <= 16'b0;
            end else if (prescaler_counter >= prescaler) begin
                // Reached prescaler value, generate enable pulse
                prescaled_clock_enable <= 1'b1;
                prescaler_counter <= 16'b0;
            end else begin
                // Continue counting
                prescaled_clock_enable <= 1'b0;
                prescaler_counter <= prescaler_counter + 16'b1;
            end
        end
    end
    
    // Register mode input to detect changes
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode_reg <= 2'b00;
        end else begin
            mode_reg <= mode;
        end
    end
    
    // FSM state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // FSM next state logic
    always_comb begin
        next_state = current_state;
        load_counter = 1'b0;
        counter_enable = 1'b0;
        
        case (current_state)
            IDLE: begin
                // Wait for start signal and valid mode
                if (start && (mode != 2'b00)) begin
                    next_state = RUNNING;
                    load_counter = 1'b1; // Load counter when starting
                end
            end
            
            RUNNING: begin
                // Enable counting when prescaler allows it
                counter_enable = prescaled_clock_enable;
                
                // Check for mode change to off or completion conditions
                if (mode == 2'b00) begin
                    // Mode changed to off - return to idle
                    next_state = IDLE;
                end else if (current_count == 32'b0) begin
                    // Counter reached zero
                    if (mode == 2'b01) begin
                        // One-shot mode: complete and stop
                        next_state = IDLE;
                    end else begin
                        // Periodic or PWM mode: reload and continue
                        load_counter = 1'b1;
                    end
                end
            end
        endcase
    end
    
    // Down counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_count <= 32'b0;
        end else begin
            if (load_counter) begin
                // Load the counter with reload value
                current_count <= reload_val;
            end else if (counter_enable && (current_count != 32'b0)) begin
                // Decrement counter when enabled and not zero
                current_count <= current_count - 32'b1;
            end
        end
    end
    
    // Timeout pulse generation (for one-shot and periodic modes)
    always_comb begin
        timeout = 1'b0;
        // Generate timeout pulse when counter reaches zero in non-PWM modes
        if ((current_count == 32'b0) && (mode != 2'b11) && (current_state == RUNNING)) begin
            timeout = 1'b1;
        end
    end
    
    // PWM output generation
    always_comb begin
        pwm_out = 1'b0;
        // Generate PWM output when in PWM mode and running
        if ((mode == 2'b11) && (current_state == RUNNING)) begin
            // Output high when count > compare value, low otherwise
            pwm_out = (current_count > compare_val);
        end
    end

endmodule
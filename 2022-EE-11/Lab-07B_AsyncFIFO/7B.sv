module asynchronous_fifo #(
    parameter int DEPTH = 8,
    parameter int DATA_WIDTH = 8
) (
    input logic wclk, wrst_n,
    input logic rclk, rrst_n,
    input logic w_en, r_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full, empty
);

    localparam int PTR_WIDTH = $clog2(DEPTH);
    
    logic [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
    logic [PTR_WIDTH:0] b_wptr, b_rptr;
    logic [PTR_WIDTH:0] g_wptr, g_rptr;

    // Synchronizers for clock domain crossing
    synchronizer #(.WIDTH(PTR_WIDTH)) sync_wptr (
        .clk(rclk), 
        .rst_n(rrst_n), 
        .d_in(g_wptr), 
        .d_out(g_wptr_sync)
    );
    
    synchronizer #(.WIDTH(PTR_WIDTH)) sync_rptr (
        .clk(wclk), 
        .rst_n(wrst_n), 
        .d_in(g_rptr), 
        .d_out(g_rptr_sync)
    );

    // Write pointer handler
    wptr_handler #(.PTR_WIDTH(PTR_WIDTH)) wptr_h (
        .wclk(wclk), 
        .wrst_n(wrst_n), 
        .w_en(w_en), 
        .g_rptr_sync(g_rptr_sync), 
        .b_wptr(b_wptr), 
        .g_wptr(g_wptr),
        .full(full)
    );
    
    // Read pointer handler
    rptr_handler #(.PTR_WIDTH(PTR_WIDTH)) rptr_h (
        .rclk(rclk), 
        .rrst_n(rrst_n), 
        .r_en(r_en), 
        .g_wptr_sync(g_wptr_sync), 
        .b_rptr(b_rptr), 
        .g_rptr(g_rptr),
        .empty(empty)
    );
    
    // FIFO memory
    fifo_mem #(
        .DEPTH(DEPTH), 
        .DATA_WIDTH(DATA_WIDTH), 
        .PTR_WIDTH(PTR_WIDTH)
    ) fifom (
        .wclk(wclk), 
        .w_en(w_en), 
        .rclk(rclk), 
        .r_en(r_en), 
        .b_wptr(b_wptr[PTR_WIDTH-1:0]),  // Use only address bits
        .b_rptr(b_rptr[PTR_WIDTH-1:0]),  // Use only address bits
        .data_in(data_in), 
        .full(full), 
        .empty(empty), 
        .data_out(data_out)
    );

endmodule

module synchronizer #(
    parameter int WIDTH = 3
) (
    input logic clk, rst_n,
    input logic [WIDTH:0] d_in,
    output logic [WIDTH:0] d_out
);

    logic [WIDTH:0] q1;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= '0;
            d_out <= '0;
        end else begin
            q1 <= d_in;
            d_out <= q1;
        end
    end

endmodule

module wptr_handler #(
    parameter int PTR_WIDTH = 3
) (
    input logic wclk, wrst_n, w_en,
    input logic [PTR_WIDTH:0] g_rptr_sync,
    output logic [PTR_WIDTH:0] b_wptr, g_wptr,
    output logic full
);

    logic [PTR_WIDTH:0] b_wptr_next;
    logic [PTR_WIDTH:0] g_wptr_next;
    logic wfull;

    assign b_wptr_next = b_wptr + (w_en & !full);
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
    
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= '0;
            g_wptr <= '0;
        end else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
        end
    end
    
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            full <= 1'b0;
        end else begin
            full <= wfull;
        end
    end
    
    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule

module rptr_handler #(
    parameter int PTR_WIDTH = 3
) (
    input logic rclk, rrst_n, r_en,
    input logic [PTR_WIDTH:0] g_wptr_sync,
    output logic [PTR_WIDTH:0] b_rptr, g_rptr,
    output logic empty
);

    logic [PTR_WIDTH:0] b_rptr_next;
    logic [PTR_WIDTH:0] g_rptr_next;
    logic rempty;

    assign b_rptr_next = b_rptr + (r_en & !empty);
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    assign rempty = (g_wptr_sync == g_rptr_next);
    
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= '0;
            g_rptr <= '0;
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end
    
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            empty <= 1'b1;
        end else begin
            empty <= rempty;
        end
    end

endmodule

module fifo_mem #(
    parameter int DEPTH = 8, 
    parameter int DATA_WIDTH = 8, 
    parameter int PTR_WIDTH = 3
) (
    input logic wclk, w_en, rclk, r_en,
    input logic [PTR_WIDTH-1:0] b_wptr, b_rptr,  // Address bits only
    input logic [DATA_WIDTH-1:0] data_in,
    input logic full, empty,
    output logic [DATA_WIDTH-1:0] data_out
);

    logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];
    
    // Write operation
    always_ff @(posedge wclk) begin
        if (w_en & !full) begin
            fifo[b_wptr] <= data_in;
        end
    end
    
    // Read operation - combinational output for better timing
    assign data_out = fifo[b_rptr];

endmodule
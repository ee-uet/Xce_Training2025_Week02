module baud_rate
	#(parameter BAUDE_RATE = 115200,
	 parameter CLK_FREQ = 50000000,
	 parameter SAMPLE = 16,
	 parameter BAUD_DIVISOR_TX = CLK_FREQ/BAUDE_RATE,
	 parameter BAUD_DIVISOR_RX = CLK_FREQ/(SAMPLE*BAUDE_RATE),
	 parameter COUNT_TX_WIDTH = $clog2(BAUD_DIVISOR_TX),
	 parameter COUNT_RX_WIDTH = $clog2(BAUD_DIVISOR_RX)
	 )
	(input logic clk, rst,
	 output logic tick_tx, tick_rx
	);
		
	logic [COUNT_TX_WIDTH-1 : 0] count_tx;
	logic [COUNT_RX_WIDTH-1 : 0] count_rx;
	
	always_ff @(posedge clk or negedge rst) begin
	if(!rst) begin
		count_rx <= '0;
		count_tx <= '0;
		tick_rx <= 1'b0;
		tick_tx <= 1'b0;
	end
	else begin
		if (count_tx == (BAUD_DIVISOR_TX-1)) begin
			tick_tx <= 1'b1;
			count_tx <= '0;
		end
		
		else begin
			tick_tx <= 1'b0;
			count_tx <= count_tx + 1;
		end
		
		if (count_rx == (BAUD_DIVISOR_RX-1)) begin
			tick_rx <= 1'b1;
			count_rx <= '0;
		end
		else begin
			tick_rx <= 1'b0;
			count_rx <= count_rx + 1;
		end
	end
end
endmodule
		
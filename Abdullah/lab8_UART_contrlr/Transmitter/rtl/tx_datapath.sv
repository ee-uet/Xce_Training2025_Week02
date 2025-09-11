module tx_datapath(
		input logic clk, rst,
		input logic tx_start, load, tx_done, tick_tx,
		input logic [7:0] data_in,
		output logic tx,load_done, transmit_done
		);
		
		logic [11:0] tx_data;
		logic [3:0] count_x = 4'b0000;
		logic parity_bit;
		logic [1:0] stop = 2'b11;
		
		always_ff @(posedge clk or negedge rst) begin
			if(!rst) begin
				count_x <=4'b0000;
				
				load_done <= 1'b0;
		
				
			end
			else begin
				if(!tx_start && load) begin
				
					tx_data [0] <= tx_start;
					tx_data [8:1] <= data_in;
					
					
					tx_data [9] <= parity_bit;
					tx_data [11:10] <= stop;
					
					load_done <= 1'b1;
				end
				else if (tx_done && tick_tx) begin
				
					load_done <= 1'b0;
					tx_data <= tx_data >> 1;
					count_x <= count_x + 1;
					end
				else if (count_x == 4'b1100) begin
						count_x = 4'b0000;
					end
				
				
			
		end
	end
	always_comb begin
	if (count_x >= 4'b1100) begin
		transmit_done = 1'b1;
		
		end
	else begin
		transmit_done = 1'b0;
		end
	parity_bit = ^data_in;
	end
	always_ff @(posedge tick_tx) begin
		
		tx <= (tx_done && !transmit_done) ? tx_data[0] : 1'b1;
	end
endmodule
		
		
		
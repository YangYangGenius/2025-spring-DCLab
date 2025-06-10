/* 
Button_Array.sv
 * 2025.06.04
 * 這是專門給GPIO按鈕debounce的模組。
*/

module Debounce_GPIO(
	input  i_in,
	input  i_clk,
	input  i_rst_n,
	output o_debounced,
	output o_neg,
	output o_pos
);

parameter CNT_N = 8191;
localparam CNT_BIT = $clog2(CNT_N+1);

wire inv_i_in;
assign inv_i_in = ~i_in;

logic debounced_r, debounced_w;
logic [CNT_BIT-1:0] counter_r, counter_w;
logic neg_r, neg_w, pos_r, pos_w;

assign o_debounced = debounced_r;
assign o_pos = pos_r;
assign o_neg = neg_r;

always_comb begin
	if(inv_i_in != debounced_r) begin
		counter_w = counter_r - 1;
	end
	else begin
		counter_w = CNT_N;
	end
end

always_comb begin
	if(counter_r == 0) begin
		debounced_w = inv_i_in;
		pos_w = ~debounced_r & inv_i_in;
		neg_w = debounced_r & ~inv_i_in;
	end
	else begin
		debounced_w = debounced_r;
		pos_w = 1'b0;
		neg_w = 1'b0;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		debounced_r <= '0;
		counter_r <= CNT_N;
		neg_r <= '0;
		pos_r <= '0;
	end else begin
		debounced_r <= debounced_w;
		counter_r <= counter_w;
		neg_r <= neg_w;
		pos_r <= pos_w;
	end
end

endmodule

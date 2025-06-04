/* * Button_Array.sv
 * 2025.06.04
 * This module debounces a set of 25 buttons connected to GPIO pins.
 * It outputs the debounced state and the positive edge detection for each button.
 * Submodules Debounce_GPIO.sv are used for debouncing each button individually.
 * 建議直接寫在DE2_115.sv中，再把o_down和o_pos連接到Main.sv中。
*/

module Button_Array(
    input i_clk,
    input i_rst_n,
    input [24:0] i_GPIO_BTN,
    output [24:0] o_down,
	output [24:0] o_pos
);

parameter NUM_BTNS = 25; 

reg  [NUM_BTNS-1:0] down_r, pos_r;
wire [NUM_BTNS-1:0] down_w, pos_w;

assign o_down = down_r;
assign o_pos = pos_r;

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		down_r <= 25'b0;
		pos_r <= 25'b0;
	end else begin
		down_r <= down_w;
		pos_r <= pos_w;
	end
end


Debounce_GPIO debounce_0(
	.i_in(i_GPIO_BTN[0]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[0]),
	.o_pos(pos_w[0])
);
Debounce_GPIO debounce_1(
	.i_in(i_GPIO_BTN[1]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[1]),
	.o_pos(pos_w[1])
);
Debounce_GPIO debounce_2(
	.i_in(i_GPIO_BTN[2]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[2]),
	.o_pos(pos_w[2])
);
Debounce_GPIO debounce_3(
	.i_in(i_GPIO_BTN[3]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[3]),
	.o_pos(pos_w[3])
);
Debounce_GPIO debounce_4(
	.i_in(i_GPIO_BTN[4]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[4]),
	.o_pos(pos_w[4])
);
Debounce_GPIO debounce_5(
	.i_in(i_GPIO_BTN[5]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[5]),
	.o_pos(pos_w[5])
);
Debounce_GPIO debounce_6(
	.i_in(i_GPIO_BTN[6]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[6]),
	.o_pos(pos_w[6])
);
Debounce_GPIO debounce_7(
	.i_in(i_GPIO_BTN[7]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[7]),
	.o_pos(pos_w[7])
);
Debounce_GPIO debounce_8(
	.i_in(i_GPIO_BTN[8]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[8]),
	.o_pos(pos_w[8])
);
Debounce_GPIO debounce_9(
	.i_in(i_GPIO_BTN[9]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[9]),
	.o_pos(pos_w[9])
);
Debounce_GPIO debounce_10(
	.i_in(i_GPIO_BTN[10]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[10]),
	.o_pos(pos_w[10])
);
Debounce_GPIO debounce_11(
	.i_in(i_GPIO_BTN[11]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[11]),
	.o_pos(pos_w[11])
);
Debounce_GPIO debounce_12(
	.i_in(i_GPIO_BTN[12]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[12]),
	.o_pos(pos_w[12])
);
Debounce_GPIO debounce_13(
	.i_in(i_GPIO_BTN[13]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[13]),
	.o_pos(pos_w[13])
);
Debounce_GPIO debounce_14(
	.i_in(i_GPIO_BTN[14]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[14]),
	.o_pos(pos_w[14])
);
Debounce_GPIO debounce_15(
	.i_in(i_GPIO_BTN[15]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[15]),
	.o_pos(pos_w[15])
);
Debounce_GPIO debounce_16(
	.i_in(i_GPIO_BTN[16]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[16]),
	.o_pos(pos_w[16])
);
Debounce_GPIO debounce_17(
	.i_in(i_GPIO_BTN[17]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[17]),
	.o_pos(pos_w[17])
);	
Debounce_GPIO debounce_18(
	.i_in(i_GPIO_BTN[18]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[18]),
	.o_pos(pos_w[18])
);
Debounce_GPIO debounce_19(
	.i_in(i_GPIO_BTN[19]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[19]),
	.o_pos(pos_w[19])
);
Debounce_GPIO debounce_20(
	.i_in(i_GPIO_BTN[20]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[20]),
	.o_pos(pos_w[20])
);
Debounce_GPIO debounce_21(
	.i_in(i_GPIO_BTN[21]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[21]),
	.o_pos(pos_w[21])
);
Debounce_GPIO debounce_22(
	.i_in(i_GPIO_BTN[22]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[22]),
	.o_pos(pos_w[22])
);
Debounce_GPIO debounce_23(
	.i_in(i_GPIO_BTN[23]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[23]),
	.o_pos(pos_w[23])
);
Debounce_GPIO debounce_24(
	.i_in(i_GPIO_BTN[24]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_debounced(down_w[24]),
	.o_pos(pos_w[24])
);





endmodule
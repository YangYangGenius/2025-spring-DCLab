module Button_array(
    input i_clk,
    input i_rst_n,
    input [11:0] i_GPIO_BTN, //6*6個按鈕輸入
    output [35:0] o_sound_number 
);

Debounce debounce_0(
	i_in(),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(),
	o_neg(),
	o_pos(),
);

Debounce debounce_1(
	i_in(),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(),
	o_neg(),
	o_pos(),
);





endmodule
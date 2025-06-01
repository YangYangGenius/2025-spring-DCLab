module Button_array(
    input i_clk,
    input i_rst_n,
    input [11:0] i_GPIO_BTN, //6*6個按鈕輸入
    output [35:0] o_sound_number 
);

logic [11:0] button_down; //接debounced結果
reg  [35:0] sound_number_r;
wire [35:0] sound_number_w;

assign o_sound_number = sound_number_r;

genvar i, j;
generate
    for (i = 0; i < 6; i++) begin : gen_i
        for (j = 0; j < 6; j++) begin : gen_j
            assign sound_number_w[i*6 + j] = button_down[i+6] & button_down[j];
        end
    end
endgenerate


always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		sound_number_r <= 36'b0;
	end else begin
		sound_number_r <= sound_number_w;
	end
end


Debounce debounce_0(
	i_in(i_GPIO_BTN[0]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[0])
);

Debounce debounce_1(
	i_in(i_GPIO_BTN[1]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[1])
);

Debounce debounce_2(
	i_in(i_GPIO_BTN[2]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[2])
);

Debounce debounce_3(
	i_in(i_GPIO_BTN[3]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[3])
);

Debounce debounce_4(
	i_in(i_GPIO_BTN[4]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[4])
);

Debounce debounce_5(
	i_in(i_GPIO_BTN[5]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[5])
);

Debounce debounce_6(
	i_in(i_GPIO_BTN[6]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[6])
);

Debounce debounce_7(
	i_in(i_GPIO_BTN[7]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[7])
);

Debounce debounce_8(
	i_in(i_GPIO_BTN[8]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[8])
);

Debounce debounce_9(
	i_in(i_GPIO_BTN[9]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[9])
);

Debounce debounce_10(
	i_in(i_GPIO_BTN[10]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[10])
);

Debounce debounce_11(
	i_in(i_GPIO_BTN[11]),
	i_clk(i_clk),
	i_rst_n(i_rst_n),
	o_debounced(button_down[11])
);

endmodule
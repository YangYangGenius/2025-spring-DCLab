module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

wire [24:0] GPIO_down, GPIO_pos, GPIO_neg;

Button_Array button_array(
	.i_clk(CLOCK_50), //CLK_25M
	.i_rst_n(KEY[3]),
	.i_GPIO_BTN(GPIO[24:0]),
	.o_down(GPIO_down),
	.o_pos(GPIO_pos),
	.o_neg(GPIO_neg)
);

logic key0down, key1down, key2down, key3down;
logic CLK_12M, CLK_100K, CLK_800K, CLK_25M;

wire [6:0] hex76, hex54, hex32, hex10;

assign AUD_XCK = CLK_12M;

Altpll pll0( // generate with qsys, please follow lab2 tutorials
	.clk_clk(CLOCK_50),
	.reset_reset_n(KEY[3]),
	.altpll_12m_clk(CLK_12M),
	.altpll_100k_clk(CLK_100K),
	.altpll_800k_clk(CLK_800K),
	.altpll_25m_clk(CLK_25M)
);

// you can decide key down settings on your own, below is just an example
// Debounce deb0(
// 	.i_in(KEY[0]), // Record/Pause
// 	.i_rst_n(KEY[3]),
// 	.i_clk(CLK_12M),
// 	.o_neg(key0down) 
// );
Debounce deb0(
	.i_in(KEY[0]), // Play/Pause
	.i_rst_n(KEY[3]),
	.i_clk(CLOCK_50),
	.o_neg(key0down) 
);

Debounce deb1(
	.i_in(KEY[1]), // Play/Pause
	.i_rst_n(KEY[3]),
	.i_clk(CLOCK_50),
	.o_neg(key1down) 
);

Debounce deb2(
	.i_in(KEY[2]), // Stop
	.i_rst_n(KEY[3]),
	.i_clk(CLOCK_50),
	.o_neg(key2down) 
);

Main main0(
	.i_rst_n(KEY[3]),
	.i_clk(CLOCK_50),
	.i_key_0(key0down),
	.i_key_1(key1down),
	.i_key_2(key2down),

	.i_GPIO_down(GPIO_down), // [24:0]
	.i_GPIO_pos(GPIO_pos), // [24:0]
	.i_GPIO_neg(GPIO_neg), // [24:0]
	
	// SRAM
	.o_SRAM_ADDR(SRAM_ADDR), // [19:0]
	.io_SRAM_DQ(SRAM_DQ), // [15:0]
	.o_SRAM_WE_N(SRAM_WE_N),
	.o_SRAM_CE_N(SRAM_CE_N),
	.o_SRAM_OE_N(SRAM_OE_N),
	.o_SRAM_LB_N(SRAM_LB_N),
	.o_SRAM_UB_N(SRAM_UB_N),
	
	// I2C
	.i_clk_100k(CLK_100K),
	.o_I2C_SCLK(I2C_SCLK),
	.io_I2C_SDAT(I2C_SDAT),
	
	// AudPlayer
	.i_AUD_ADCDAT(AUD_ADCDAT),
	.i_AUD_ADCLRCK(AUD_ADCLRCK),
	.i_AUD_BCLK(AUD_BCLK),
	.i_AUD_DACLRCK(AUD_DACLRCK),
	.o_AUD_DACDAT(AUD_DACDAT),

	// Slide Switches
	.i_slide_switches(SW), // [17:0]

	// Seven HEX Decoder (optional display)
	.o_hex76(hex76), // [6:0]
	.o_hex54(hex54), // [6:0]
	.o_hex32(hex32), // [6:0]
	.o_hex10(hex10), // [6:0]

	//測試beat
	.o_hex3(o_B_HEX3), // [6:0]
	.o_hex2(o_B_HEX2), // [6:0]
	.o_hex1(o_B_HEX1), // [6:0]
	.o_hex0(o_B_HEX0), // [6:0]

	// LED
	.o_ledg(LEDG), // [8:0]
	.o_ledr(LEDR), // [17:0]

	// LCD
	.o_LCD_ON(LCD_ON),
	.o_LCD_BLON(LCD_BLON),
	.o_LCD_EN(LCD_EN),
	.o_LCD_RS(LCD_RS),
	.o_LCD_RW(LCD_RW),
	.o_LCD_DATA(LCD_DATA) // [7:0]

);

wire [6:0] o_HEX0, o_HEX1, o_HEX2, o_HEX3;
wire [6:0] o_B_HEX0, o_B_HEX1, o_B_HEX2, o_B_HEX3;

assign HEX0 = (SW[15])? o_HEX0 : o_B_HEX0;
assign HEX1 = (SW[15])? o_HEX1 : o_B_HEX1;
assign HEX2 = (SW[15])? o_HEX2 : o_B_HEX2;
assign HEX3 = (SW[15])? o_HEX3 : o_B_HEX3;

SevenHexDecoder seven_dec76(
	.i_hex(hex76),
	.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);

SevenHexDecoder seven_dec54(
	.i_hex(hex54),
	.o_seven_ten(HEX5),
	.o_seven_one(HEX4)
);




SevenHexDecoder seven_dec32(
	.i_hex(hex32),
	.o_seven_ten(o_HEX3),
	.o_seven_one(o_HEX2)
);

SevenHexDecoder seven_dec10(
	.i_hex(hex10),
	.o_seven_ten(o_HEX1),
	.o_seven_one(o_HEX0)
);

// comment what are used for display
//assign HEX0 = '1;
//assign HEX1 = '1;
//assign HEX2 = '1;
//assign HEX3 = '1;
//assign HEX4 = '1;
//assign HEX5 = '1;
//assign HEX6 = '1;
//assign HEX7 = '1;

endmodule

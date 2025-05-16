module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0, //Record & Pause
	input i_key_1, // Stop
	input i_key_2, //Play & Pause
	
	input [2:0] i_speed,
	input i_slow_mode,
	input i_is_slow, 
	input i_remain_pitch, // design how user can decide mode on your own

	//mixer
	input i_mixer, // design how user can decide mode on your own

	// input [3:0] i_speed, // design how user can decide mode on your own
	
// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
// AudPlayer 揚
	inout  i_AUD_BCLK, 		//Audio CODEC Bit-Steam Clock時鐘 	(master mode->這邊是input)
	inout  i_AUD_ADCLRCK,	//Audio CODEC ADC LR Clock時鐘		(master mode->這邊是input)
	inout  i_AUD_DACLRCK,	//Audio CODEC DAC LR Clock時鐘		(master mode->這邊是input)
	input  i_AUD_ADCDAT,	//Audio CODEC ADC Data
	output o_AUD_DACDAT,		//Audio CODEC DAC Data


// SEVENDECODER (optional display)
	output [6:0] o_time,
	output [6:0] o_time_2,
	// output [5:0] o_play_time,

// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

// LED
	output  [8:0] o_ledg,
	output [17:0] o_ledr
);


//FSM
parameter S_IDLE       = 0; 
parameter S_I2C        = 1;
parameter S_RECD_WAIT  = 2;
parameter S_RECD       = 3;
parameter S_RECD_PAUSE = 4;
parameter S_RECD_TAKEN = 5;
parameter S_PLAY       = 6;
//parameter S_PLAY_PAUSE = 7; //不會用到
logic [2:0] state_r, state_w;

//button init
logic key_record, key_stop, key_play;
assign key_record = (state_r != S_PLAY)? i_key_0 : 0;
assign key_stop   = i_key_1;
assign key_play   = (state_r == S_RECD_TAKEN || state_r == S_PLAY) ? i_key_2 : 0;

//Stop control
parameter STOP_ADDR_COUNT = 20'hfffff;
logic stop_r, stop_w;



// I2C control signals
logic i2c_oen, i2c_sdat; // 助教
wire i2c_finished; 
logic i2c_start_r, i2c_start_w; //不用w
//assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz; // 助教


// Submodule AudRecorder & Player
logic [19:0] addr_record, addr_play; // 助教
logic [15:0] data_record, data_play, dac_data; // 助教
wire record_valid;
wire [19:0] stop_address; 
wire [6:0] record_state; // debug purpose
assign o_ledr = {11'b0,record_state};


// DSP temporary signals TODO 因為是借用
logic dsp_start_r, dsp_start_w;
always_comb begin
		if(key_play) 							dsp_start_w = 1'b1;
		//else if(state_r == S_PLAY && key_stop) 	dsp_start_w = 1'b1;
		else         							dsp_start_w = 1'b0;
end

//0516 mixer experiment
reg  [15:0] mixer_data_r;
wire [15:0] mixer_data_w;
wire [16:0] mixed_data_pre;
wire [15:0] mixed_data;
assign mixer_data_w = (!record_valid) ? io_SRAM_DQ : 16'd0;
assign mixed_data = mixer_data_r + data_record;


// SRAM & Submodule AudDSP
assign o_SRAM_ADDR = (state_r == S_PLAY) ? addr_play : addr_record;
assign io_SRAM_DQ  = (record_valid) ? ( i_mixer ? mixed_data : data_record)  : 16'dz; // sram_dq as output
assign data_play   = (!record_valid) ? io_SRAM_DQ : 16'd0; // sram_dq as input

// SRAM control signals 助教
assign o_SRAM_WE_N = (record_valid) ? 1'b0 : 1'b1; //SRAM_WE_N 設定目前操作模式， 0 為寫， 1 為讀 
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

//Output Monitor
wire[9:0] mili_0;
assign o_time = (state_r == S_RECD || state_r == S_RECD_PAUSE) ? {2'b00, addr_record[19:15]} : {2'b00, addr_play[19:15]};
assign mili_0 = (state_r == S_RECD || state_r == S_RECD_PAUSE) ? addr_record[14:5] : addr_play[14:5];
assign o_ledg = (state_r == S_IDLE) ? 		9'b111111111 :
				(state_r == S_I2C) ? 		9'b000000001 : 
				(state_r == S_RECD_WAIT) ? 	9'b000000010 : 
				(state_r == S_RECD) ?		9'b000000100 :
				(state_r == S_RECD_PAUSE) ? 9'b000001000 :
				(state_r == S_RECD_TAKEN) ? 9'b000010000 :
				(state_r == S_PLAY) ?		9'b000100000 : 9'b000000000;


// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start_r),
	.o_finished(i2c_finished),
	.o_sclk(o_I2C_SCLK),
	.io_sdat(io_I2C_SDAT), // i2c_sdat有問題
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0( //
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(key_record),
	.i_pause(key_record),
	.i_stop(stop_r),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record), //[19:0]
	.o_data(data_record),    //[15:0]
	.o_valid(record_valid),
	.o_stop_address(stop_address),
	.o_state(record_state), // debug purpose
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 

AudDSP dsp(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_BCLK),
	.i_start(dsp_start_r),
	.i_pause(key_play),
	.i_speed(i_speed), // total 3 bits, use 3 switches
	.i_is_slow(i_is_slow), // 0 for fast play, 1 for slow play, use 1 switch
	.i_slow_mode(i_slow_mode), // 0 for constant interpolation, 1 for linear interpolation, use 1 switch
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.i_sram_stop_addr(stop_address), 
	.o_dac_data(dac_data),
	.o_en(dsp_oen),
	.o_is_pause(is_player_pause),
	.o_sram_addr(addr_play)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(dsp_oen), 				// 用DSP控制，但好像可以直接用(!i_AUD_DACLRCK)	enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), 	//dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);


// millisecond mili0(
//     .a(mili_0),
//     .b(o_time_2) // 7 bits;
// );
wire [14:0] a_extended;
wire [14:0] sum;
assign a_extended = {5'b0, mili_0}; // Extend a to 15 bits by adding 5 leading zeros
assign sum = a_extended + (a_extended << 3) + (a_extended << 4); // Multiply by 25
assign o_time_2 = sum[14:8];



//stop control TODO
always_comb begin
	if (addr_record == STOP_ADDR_COUNT)	stop_w = 1'b1;
	else if (key_stop) 					stop_w = 1'b1;
	else 								stop_w = 1'b0;
end

//I2C control signals
always_comb begin
	if (state_r == S_I2C) i2c_start_w = 1;
	else i2c_start_w = 0;
end

// FSM
always_comb begin
	state_w = state_r;
	case(state_r)
		S_IDLE: begin
			state_w = S_I2C;
		end
		S_I2C: begin
			if (i2c_finished) 		state_w = S_RECD_WAIT;
		end
		S_RECD_WAIT: begin
			if (key_record) 		state_w = S_RECD;
		end
		S_RECD: begin
			if (stop_r)				state_w = S_RECD_TAKEN;
			else if (key_record)	state_w = S_RECD_PAUSE;
		end
		S_RECD_PAUSE: begin
			if (stop_r)				state_w = S_RECD_TAKEN;
			else if (key_record)	state_w = S_RECD;
		end
		S_RECD_TAKEN: begin
			if (key_record) 		state_w = S_RECD;
			else if (key_play)		state_w = S_PLAY;
		end 
		S_PLAY: begin 
			if (stop_r)				state_w = S_RECD_TAKEN;
			else if (key_play)		state_w = S_PLAY;//state_w = S_PLAY_PAUSE;
		end
		default: state_w = state_r;
	endcase
	
end

always_ff @(posedge i_clk or negedge i_rst_n) begin //i_AUD_BCLK
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		stop_r <= 1'b0;

		//DSP temporary signals
		dsp_start_r <= 1'b0;
		i2c_start_r <= 0;

		//mixer
		mixer_data_r <= 16'd0;

	end
	else begin
		state_r <= state_w;
		stop_r <= stop_w;

		//DSP temporary signals
		dsp_start_r <= dsp_start_w;
		i2c_start_r <= i2c_start_w;

		//mixer
		mixer_data_r <= mixer_data_w;

	end
end

endmodule

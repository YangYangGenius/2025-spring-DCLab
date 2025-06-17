//-------------------------------------
// 關於Main Module: 
//-------------------------------------
    /*
    1. 所有算法跟DE2-115連接的媒介
    2.
    3.
    4.
    5.
    */

module Main(
    
    input i_clk,
    input i_rst_n,

    input i_key_0,
	input i_key_1,
	input i_key_2,

    input [24:0] i_GPIO_down, // [24:0] i_GPIO_down
    input [24:0] i_GPIO_pos, // [24:0] i_GPIO_pos
    input [24:0] i_GPIO_neg, // [24:0] i_GPIO_neg
    
    //SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,

    // I2C interface
    input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,

    // AudPlayer 揚
	inout  i_AUD_BCLK, 		//Audio CODEC Bit-Steam Clock時鐘 	(master mode->這邊是input)
	inout  i_AUD_ADCLRCK,	//Audio CODEC ADC LR Clock時鐘		(master mode->這邊是input)
	inout  i_AUD_DACLRCK,	//Audio CODEC DAC LR Clock時鐘		(master mode->這邊是input)
	input  i_AUD_ADCDAT,	//Audio CODEC ADC Data
	output o_AUD_DACDAT,		//Audio CODEC DAC Data
    
    // Slide Switches
    input [17:0] i_slide_switches, // [17:0] i_slide_switches

    // Seven HEX Decoder (optional display)
	output [6:0] o_hex76,
    output [6:0] o_hex54,
    output [6:0] o_hex32,
    output [6:0] o_hex10,

    output [6:0] o_hex3,
    output [6:0] o_hex2,
    output [6:0] o_hex1,
    output [6:0] o_hex0,

    // LED
	output  [8:0] o_ledg,
	output [17:0] o_ledr,

    // LCD
    output o_LCD_BLON,
    output o_LCD_ON,
    output o_LCD_EN,  // LCD Enable signal
    output o_LCD_RS,
    output o_LCD_RW,
    output [7:0] o_LCD_DATA
);

assign io_SRAM_DQ  = 16'bz; // 當讀取SRAM時，將io_SRAM_DQ設為高阻抗，否則設為sram_data
assign o_SRAM_WE_N = 1'b1; // SRAM_WE_N 設定目前操作模式， 1 為讀， 0 為寫
assign o_SRAM_CE_N = 1'b0; // SRAM chip enable signal, active low
assign o_SRAM_OE_N = 1'b0; // SRAM output enable signal, active low
assign o_SRAM_LB_N = 1'b0; // SRAM lower byte enable signal, active low
assign o_SRAM_UB_N = 1'b0; // SRAM upper byte enable signal, active low

wire play_pause = i_key_2; // 播放/暫停按鍵

wire i2c_start;
wire i2c_finished;
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start),
	.o_finished(i2c_finished),
	.o_sclk(o_I2C_SCLK),
	.io_sdat(io_I2C_SDAT), // i2c_sdat有問題
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
wire [15:0] dac_data; // DAC數據
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
    .i_dac_data(dac_data), 	// [15:0] dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// ---------- Wave Calculation ---------- //

wire [31:0] theta_w [0:24]; // 用於存儲每個按鈕的角度值
Theta theta0(
    .time_r(time_r), // 20 bits
    .o_theta(theta_w) // 32 bits x 25
);

wire [32:0] current_pressed_data = (time_in_sound_pos_cycle-1 < MAX_PRESSED_COUNT && time_in_sound_pos_cycle-1 < pressed_count_r) ? pressed_data_r[time_in_sound_pos_cycle-1] : 0;

wire [15:0] square_wave_output;
SquareWave square_wave0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .tp(time_in_sound_pos_cycle), // time_in_sound_pos_cycle
    .i_data(current_pressed_data), // 33 bits
    .time_r(time_r), // 20 bits
    .theta(theta_w), // [31:0] theta for each button
    .o_square(square_wave_output) // 16 bits
);

wire [15:0] saw_wave_output;
SawWave saw_wave0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .tp(time_in_sound_pos_cycle), // time_in_sound_pos_cycle
    .i_data(current_pressed_data), // 33 bits
    .time_r(time_r), // 20 bits
    .theta(theta_w), // [31:0] theta for each button
    .o_saw(saw_wave_output) // 16 bits
);

wire [15:0] trig_wave_output;
TrigWave trig_wave0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .tp(time_in_sound_pos_cycle), // time_in_sound_pos_cycle
    .i_data(current_pressed_data), // 33 bits
    .time_r(time_r), // 20 bits
    .theta(theta_w), // [31:0] theta for each button
    .o_trig(trig_wave_output) // 16 bits
);

wire [15:0] sin_wave_output;
SinWave sin_wave0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .tp(time_in_sound_pos_cycle), // time_in_sound_pos_cycle
    .i_data(current_pressed_data), // 33 bits
    .time_r(time_r), // 20 bits
    .theta(theta_w), // [31:0] theta for each button
    .o_sin(sin_wave_output) // 16 bits
);

wire [15:0] sound_effects_output;
SoundEffects sound_effects0(
    .i_clk(i_clk), // 時鐘信號
    .i_rst_n(i_rst_n), // 復位信號，低有效
    .i_data(current_pressed_data), // 33 bits
    .time_r(time_r), // 20 bits
    .play_what_is_stored(play_what_is_stored), // 是否直接播放已存儲的音效
    .i_SRAM_DQ(io_SRAM_DQ), // [15:0] SRAM data
    .o_SRAM_ADDR(o_SRAM_ADDR), // [19:0] SRAM address
    .o_sound_effects(sound_effects_output) // 16 bits
);

wire sw8_down, sw8_pos, sw8_neg;
Debounce_GPIO debounce_sw8(
    .i_in(~i_slide_switches[8]), // Slide Switch #8
    .i_rst_n(i_rst_n), // Reset signal, active low
    .i_clk(i_clk),
    .o_debounced(sw8_down), // Output for Slide Switch #8
    .o_neg(sw8_neg), // Negative edge output for Slide Switch #8
    .o_pos(sw8_pos) // Positive edge output for Slide Switch #8
);

Beat beat0(
    .i_clk(i_clk), // 9 MHz clock
    .i_rst_n(i_rst_n), // Reset signal, active low
    .i_time(time_r), // 20 bits time input from main module

    .o_hex3(o_hex3),
    .o_hex2(o_hex2),
    .o_hex1(o_hex1),
    .o_hex0(o_hex0)
);

// ---------- Local Parameters ---------- //
localparam S_IDLE = 0;
localparam S_I2C = 1;
localparam S_PLAY = 2;
localparam S_PAUSE = 3;

localparam AMPLITUDE = 600; // 音量幅度


// ---------- Finite State Machine ---------- //
logic [5:0] state_r;
logic [5:0] state_w; 
always_comb begin
    state_w = state_r; // 預設情況下，保持當前狀態
    case (state_r)
        S_IDLE: begin
            state_w = S_I2C; // 當狀態為S_IDLE時，轉移到S_I2C
        end
        S_I2C: begin
            if (i2c_finished) begin
                state_w = S_PAUSE; // 當I2C初始化完成時，轉移到S_PLAY
            end
        end
        S_PLAY: begin
            if (play_pause) begin
                state_w = S_PAUSE; // 當播放/暫停按鍵被按下時，轉移到S_PAUSE
            end
        end
        S_PAUSE: begin
            if (play_pause) begin
                state_w = S_PLAY; // 當播放/暫停按鍵被按下時，轉移到S_PLAY
            end
        end
        default: begin
            state_w = state_r; // 其他情況下，保持當前狀態
        end
    endcase
end


// ---------- logicisters & Wires ---------- //
logic [19:0] time_r; // 用於計時的寄存器
wire [19:0] time_w; // 用於計時的線網
assign time_w = (state_r == S_PLAY && time_r != 20'b0111_1111_1111_1111_1111) ? time_r + 1 : // 當狀態為S_PLAY時，計時器增加
                (state_r == S_PAUSE) ? time_r : // 當狀態為S_PAUSE時，保持計時器不變
                0; // 其他情況下，計時器歸零

logic [15:0] time_in_sound_pos_cycle; // 用於計算音效循環中的時間, should be within 0 ~ 1563
logic [15:0] time_in_sound_neg_cycle; // 用於計算音效循環中的時間, should be within 0 ~ 1563

logic [15:0] pressed_count_r, pressed_count_ckpt_r; // 記錄已按下的音效數量
logic [15:0] pressed_count_w, pressed_count_ckpt_w;
localparam MAX_PRESSED_COUNT = 1024; // 最大音效循環數量
logic [32:0] pressed_data_r [0:MAX_PRESSED_COUNT-1]; // 是否須記錄開始結束(1) + 開始1結束0(1) + 方/三角/正弦(2) + 音量(2) + 高幾個八度(2) + 按鈕ID(5) + 音效開始時間(20)
logic [32:0] pressed_data_w [0:MAX_PRESSED_COUNT-1];


wire [4:0] GPIO_ID_Encoder;
assign GPIO_ID_Encoder = 
    (i_GPIO_pos[0] || i_GPIO_neg[0] ) ? 5'd0 :
    (i_GPIO_pos[1] || i_GPIO_neg[1] ) ? 5'd1 :
    (i_GPIO_pos[2] || i_GPIO_neg[2] ) ? 5'd2 :
    (i_GPIO_pos[3] || i_GPIO_neg[3] ) ? 5'd3 :
    (i_GPIO_pos[4] || i_GPIO_neg[4] ) ? 5'd4 :
    (i_GPIO_pos[5] || i_GPIO_neg[5] ) ? 5'd5 :
    (i_GPIO_pos[6] || i_GPIO_neg[6] ) ? 5'd6 :
    (i_GPIO_pos[7] || i_GPIO_neg[7] ) ? 5'd7 :
    (i_GPIO_pos[8] || i_GPIO_neg[8] ) ? 5'd8 :
    (i_GPIO_pos[9] || i_GPIO_neg[9] ) ? 5'd9 :
    (i_GPIO_pos[10] || i_GPIO_neg[10]) ? 5'd10 :
    (i_GPIO_pos[11] || i_GPIO_neg[11]) ? 5'd11 :
    (i_GPIO_pos[12] || i_GPIO_neg[12]) ? 5'd12 :
    (i_GPIO_pos[13] || i_GPIO_neg[13]) ? 5'd13 :
    (i_GPIO_pos[14] || i_GPIO_neg[14]) ? 5'd14 :
    (i_GPIO_pos[15] || i_GPIO_neg[15]) ? 5'd15 :
    (i_GPIO_pos[16] || i_GPIO_neg[16]) ? 5'd16 :
    (i_GPIO_pos[17] || i_GPIO_neg[17]) ? 5'd17 :
    (i_GPIO_pos[18] || i_GPIO_neg[18]) ? 5'd18 :
    (i_GPIO_pos[19] || i_GPIO_neg[19]) ? 5'd19 :
    (i_GPIO_pos[20] || i_GPIO_neg[20]) ? 5'd20 :
    (i_GPIO_pos[21] || i_GPIO_neg[21]) ? 5'd21 :
    (i_GPIO_pos[22] || i_GPIO_neg[22]) ? 5'd22 :
    (i_GPIO_pos[23] || i_GPIO_neg[23]) ? 5'd23 :
    (i_GPIO_pos[24] || i_GPIO_neg[24]) ? 5'd24 : 5'd31; // 如果沒有按下任何按鈕，則返回31


wire [4:0] GPIO_down_ID_Encoder;
assign GPIO_down_ID_Encoder = 
    i_GPIO_down[0] ? 5'd0 :
    i_GPIO_down[1] ? 5'd1 :
    i_GPIO_down[2] ? 5'd2 :
    i_GPIO_down[3] ? 5'd3 :
    i_GPIO_down[4] ? 5'd4 :
    i_GPIO_down[5] ? 5'd5 :
    i_GPIO_down[6] ? 5'd6 :
    i_GPIO_down[7] ? 5'd7 :
    i_GPIO_down[8] ? 5'd8 :
    i_GPIO_down[9] ? 5'd9 :
    i_GPIO_down[10] ? 5'd10 :
    i_GPIO_down[11] ? 5'd11 :
    i_GPIO_down[12] ? 5'd12 :
    i_GPIO_down[13] ? 5'd13 :
    i_GPIO_down[14] ? 5'd14 :
    i_GPIO_down[15] ? 5'd15 :
    i_GPIO_down[16] ? 5'd16 :
    i_GPIO_down[17] ? 5'd17 :
    i_GPIO_down[18] ? 5'd18 :
    i_GPIO_down[19] ? 5'd19 :
    i_GPIO_down[20] ? 5'd20 :
    i_GPIO_down[21] ? 5'd21 :
    i_GPIO_down[22] ? 5'd22 :
    i_GPIO_down[23] ? 5'd23 :
    i_GPIO_down[24] ? 5'd24 : 5'd31; // 如果沒有按下任何按鈕，則返回31




// wire [32:0] data_to_be_written = {i_slide_switches[7], i_GPIO_pos_all, i_slide_switches[6:1], GPIO_ID_Encoder, time_r} + 1;
// genvar i;
// generate
//     for (i = 0; i < MAX_PRESSED_COUNT; i++) begin : assign_loop
//         assign pressed_data_w[i] = (state_r == S_PLAY && i == pressed_count_r && (i_GPIO_pos_all || (i_GPIO_neg_all && i_slide_switches[7]))) ? 
//              data_to_be_written : pressed_data_r[i];
//     end
// endgenerate

// genvar i;
// logic [4:0] index_value;
// assign index_value = i - pressed_count_r;
// generate
//     for (i = 0; i < MAX_PRESSED_COUNT; i++) begin : assign_loop
//         if (i < MAX_PRESSED_COUNT - 31) begin
//             assign pressed_data_w[i] = (i_slide_switches[9] && state_r == S_PLAY && i == pressed_count_r) ? 
//                 {data_to_be_written[32:20], 5'd0, data_to_be_written[14:0]} :
//                 (state_r == S_PLAY && i == pressed_count_r && (i_GPIO_pos_all || (i_GPIO_neg_all && i_slide_switches[7]))) ?
//                 data_to_be_written :
//                 pressed_data_r[i];
//         end

//         if (i_slide_switches[9]) begin : burst_block
//             if (i >= pressed_count_r && i < pressed_count_r + 32 && i < MAX_PRESSED_COUNT) begin
//                 assign pressed_data_w[i] = {data_to_be_written[32:20], index_value, data_to_be_written[14:0]};
//             end
//         end
//     end
// endgenerate
wire [32:0] data_to_be_written = {i_slide_switches[7], i_GPIO_pos_all, i_slide_switches[6:1], GPIO_ID_Encoder, time_r} + 1;
always_comb begin
    for (int i = 0; i < MAX_PRESSED_COUNT; i++) begin
        logic [4:0] index_value;
        index_value = i - pressed_count_r;

        // Default: pass through
        pressed_data_w[i] = pressed_data_r[i];

        // Burst overwrite (takes highest priority)
        if (i_slide_switches[9] && i >= pressed_count_r && i < pressed_count_r + 16) begin
            pressed_data_w[i] = {data_to_be_written[32:20], index_value[4:0], data_to_be_written[14:0]};
        end
        // Single write at pressed_count_r
        else if (state_r == S_PLAY && i == pressed_count_r && (i_GPIO_pos_all || (i_GPIO_neg_all && i_slide_switches[7]))) begin
            pressed_data_w[i] = data_to_be_written;
        end
    end
end


wire i_GPIO_pos_all = |i_GPIO_pos; // 檢查是否有任何按鈕被按下
wire i_GPIO_neg_all = |i_GPIO_neg; // 檢查是否有任何按鈕被釋放
assign pressed_count_w = (state_r == S_PLAY && (i_GPIO_pos_all || (i_GPIO_neg_all && i_slide_switches[7]))) ? 
                                (pressed_count_r + (i_slide_switches[9] ? 16 : 1)) : // 當Slide Switch #9被打開時，增加32個音效循環數量
                        (sw8_neg) ? pressed_count_ckpt_r : // 當Slide Switch #8被釋放時，恢復到檢查點
                        (i_key_0) ? pressed_count_r - ((i_slide_switches[7]?2:1) << (i_slide_switches[9]?4:0)) : // 當按下Key #0時，減少音效循環數量
                            pressed_count_r;
assign pressed_count_ckpt_w = (sw8_pos) ? pressed_count_r : pressed_count_ckpt_r;

wire play_what_is_stored;
assign play_what_is_stored = (state_r == S_PLAY && i_slide_switches[17]); // 當狀態為S_PLAY且"滑動開關#17"被打開時，播放已存儲的音效

logic [15:0] dac_data_r; // 用於DAC的數據寄存器
logic [15:0] dac_data_w;

// wire signed [17:0] expected_dac_data = $signed(dac_data_r) + square_wave_output + saw_wave_output + trig_wave_output + sin_wave_output + sound_effects_output;
always_comb begin
    dac_data_w = dac_data_r; // 預設DAC數據為 dac_data_r
    if (state_r == S_PLAY && time_in_sound_neg_cycle < 30) begin
        // dac_data_w = dac_data_r + square_wave_output + sound_effects_output; // 當音效開關打開時，根據頻率計算DAC數據
        if (play_what_is_stored) begin
            dac_data_w = sound_effects_output; // 當播放已存儲的音效時，從SRAM讀取數據
        end
        else begin
            // dac_data_w = (expected_dac_data > 16'hFFFF) ? 16'hFFFF : expected_dac_data; // 當播放方波時，根據頻率計算DAC數據 (hard clipping)
            dac_data_w = dac_data_r + square_wave_output + saw_wave_output + trig_wave_output + sin_wave_output + sound_effects_output;
        end

    end
    else begin
        dac_data_w = 0; // 當不在播放狀態或時間超過限制時，DAC數據歸零
    end
end

assign dac_data = dac_data_r; // 將DAC數據寄存器的值輸出到DAC

// ---------- Other Assignments ---------- //
assign i2c_start = (state_r == S_I2C) ? 1'b1 : 1'b0; // 當狀態為S_I2C時，開始I2C初始化

// Seven Segment Display
assign o_hex76 = {2'b00, time_r[19:15]}; // 顯示計時器的整數秒
assign o_hex54 = pressed_count_r % 100;  // TODO: 需要根據實際需求填充
assign o_hex32 = dac_data_r[13:7];  // TODO: 需要根據實際需求填充
assign o_hex10 = dac_data_r[6:0];  // TODO: 需要根據實際需求填充

// LED Indicators
assign o_ledg = (state_r == S_IDLE) ? 9'b000000001 : // 當狀態為S_IDLE時，綠色LED亮起
                (state_r == S_I2C) ? 9'b000000010 : // 當狀態為S_I2C時，綠色LED亮起
                (state_r == S_PLAY) ? 9'b000000100 : // 當狀態為S_PLAY時，綠色LED亮起
                (state_r == S_PAUSE) ? 9'b000001000 : // 當狀態為S_PAUSE時，綠色LED亮起
                9'b000000000; // 其他情況下，所有LED熄滅

assign o_ledr = 18'b0;  // TODO

LCD lcd0(
    .clk(i_clk), // 時鐘信號
    .rst(i_rst_n), // 復位信號，低有效
    .SW(i_slide_switches), // [17:0] Slide Switches
    .BtnID(GPIO_down_ID_Encoder), // [4:0] 按鈕ID
    .LCD_ON(o_LCD_ON), // LCD開關
    .LCD_BLON(o_LCD_BLON), // LCD背光開關
    .LCD_EN(o_LCD_EN), 
    .LCD_RS(o_LCD_RS),
    .LCD_RW(o_LCD_RW),
    .LCD_DATA(o_LCD_DATA)
);



// ---------- Sequential Logic ---------- //
always_ff @(posedge i_clk or negedge i_rst_n) begin //i_AUD_BCLK
	if (!i_rst_n) begin
		state_r <= S_IDLE; // 當復位時，狀態設為S_IDLE
        pressed_count_r <= 0; // 當復位時，已按下的音效數量歸零
        pressed_count_ckpt_r <= 0; // 當復位時，已按下的音效數量檢查點歸零
        time_in_sound_pos_cycle <= 0; // 當復位時，音效循環時間歸零
        time_in_sound_neg_cycle <= 0; // 當復位時，音效循環時間歸零
        dac_data_r <= 0; // 當復位時，DAC數據寄存器歸零
        for (int i = 0; i < MAX_PRESSED_COUNT; i++) begin
            pressed_data_r[i] <= 0; // 當復位時，清空已按下的音效數據
        end
	end
	else begin
		state_r <= state_w;
        pressed_count_r <= pressed_count_w; // 更新已按下的音效數量
        pressed_count_ckpt_r <= pressed_count_ckpt_w; // 更新已按下的音效數量檢查點

        // 更新音效循環時間
        if (state_r == S_PLAY && i_AUD_DACLRCK) begin
            time_in_sound_pos_cycle <= time_in_sound_pos_cycle + 1; // 當狀態為S_PLAY時，音效循環時間增加
        end
        else begin
            time_in_sound_pos_cycle <= 0; // 其他情況下，音效循環時間歸零
        end

        // 更新音效循環時間
        if (state_r == S_PLAY && !i_AUD_DACLRCK) begin
            time_in_sound_neg_cycle <= time_in_sound_neg_cycle + 1; // 當狀態為S_PLAY時，音效循環時間增加
        end
        else begin
            time_in_sound_neg_cycle <= 0; // 其他情況下，音效循環時間歸零
        end

        dac_data_r <= dac_data_w; // 更新DAC數據寄存器

        for (int i = 0; i < MAX_PRESSED_COUNT; i++) begin
            pressed_data_r[i] <= pressed_data_w[i]; // 更新已按下的音效數據
        end

	end
end

always_ff @(posedge i_AUD_DACLRCK or negedge i_rst_n) begin
    if (!i_rst_n) begin
        time_r <= 0; // 當復位時，計時器歸零
    end
    else begin
        time_r <= time_w; // 更新計時器
    end
end

endmodule
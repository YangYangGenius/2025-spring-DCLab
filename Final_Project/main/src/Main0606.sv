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

    // input i_key_0,
    input i_key_0,
    input i_key_0_pos,
    input i_key_0_neg,
	input i_key_1,
	input i_key_2,

    input i_sw_16, i_sw_16_pos, i_sw_16_neg,
    input i_sw_15, i_sw_15_pos, i_sw_15_neg,
    input i_sw_14, i_sw_14_pos, i_sw_14_neg,
    input i_sw_13, i_sw_13_pos, i_sw_13_neg,
    input i_sw_12, i_sw_12_pos, i_sw_12_neg,
    input i_sw_11, i_sw_11_pos, i_sw_11_neg,
    input i_sw_10, i_sw_10_pos, i_sw_10_neg,
    input i_sw_9, i_sw_9_pos, i_sw_9_neg,
    
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

    // LED
	output  [8:0] o_ledg,
	output [17:0] o_ledr
);

wire is_reading_SRAM; // 用於判斷是否正在讀取SRAM
assign is_reading_SRAM = 1; // THIS IS A TEMPORARY ASSIGNMENT, SHOULD BE CHANGED LATER
assign sram_data_to_be_written = 0 ; // THIS IS A TEMPORARY ASSIGNMENT, SHOULD BE CHANGED LATER
assign io_SRAM_DQ  = (is_reading_SRAM) ? 16'dz : sram_data_to_be_written; // 當讀取SRAM時，將io_SRAM_DQ設為高阻抗，否則設為sram_data
assign o_SRAM_WE_N = is_reading_SRAM; // SRAM_WE_N 設定目前操作模式， 1 為讀， 0 為寫
assign o_SRAM_CE_N = 1'b0; // SRAM chip enable signal, active low
assign o_SRAM_OE_N = 1'b0; // SRAM output enable signal, active low
assign o_SRAM_LB_N = 1'b0; // SRAM lower byte enable signal, active low
assign o_SRAM_UB_N = 1'b0; // SRAM upper byte enable signal, active low
// Memory memory0(
//     .i_clk(i_clk),
//     .i_rst_n(i_rst_n),
//     .i_AUD_DACLRCK(i_AUD_DACLRCK),
    
//     //播放的模式 or 編輯模式
//     .i_mode(), 
    
//     //提取音效
//     .i_track_type(), 
//     .o_track_data(), //提取該音效 
    
//     //存入音樂
//     .i_data(),
//     .i_addr(),
    
//     //SRAM訊號，Main.sv直接接就好
//     .o_SRAM_ADDR(o_SRAM_ADDR),
//     .io_SRAM_DQ(io_SRAM_DQ),
//     .o_SRAM_WE_N(o_SRAM_WE_N),
//     .o_SRAM_CE_N(o_SRAM_CE_N),
//     .o_SRAM_OE_N(o_SRAM_OE_N),
//     .o_SRAM_LB_N(o_SRAM_LB_N),
//     .o_SRAM_UB_N(o_SRAM_UB_N)
// );

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

Merge merge0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_AUD_DACLRCK(i_AUD_DACLRCK), //這個是為了在DAC為了在右聲道(=1)的時候整理音訊
    
    .i_merge_mode(), //合併模式
    .i_data(), //輸入資料
    .o_data() //輸出資料
);

// ---------- Local Parameters ---------- //
localparam S_IDLE = 0;
localparam S_I2C = 1;
localparam S_PLAY = 2;
localparam S_PAUSE = 3;

wire [19:0] sound_addr [0:15]; // 音效地址陣列
assign sound_addr[0] = 20'd211400; // 音效0地址
assign sound_addr[1] = 20'd266985; // 音效1地址
assign sound_addr[2] = 20'h00000; // 音效2地址
assign sound_addr[3] = 20'h00000; // 音效3地址
assign sound_addr[4] = 20'h00000; // 音效4地址
assign sound_addr[5] = 20'h00000; // 音效5地址
assign sound_addr[6] = 20'h00000; // 音效6地址
assign sound_addr[7] = 20'h00000; // 音效7地址
assign sound_addr[8] = 20'h00000; // 音效8地址
assign sound_addr[9] = 20'h00000; // 音效9地址
assign sound_addr[10] = 20'h00000; // 音效10地址
assign sound_addr[11] = 20'h00000; // 音效11地址
assign sound_addr[12] = 20'h00000; // 音效12地址
assign sound_addr[13] = 20'h00000; // 音效13地址
assign sound_addr[14] = 20'h00000; // 音效14地址
assign sound_addr[15] = 20'h00000; // 音效15地址

wire [19:0] sound_length [0:15]; // 音效長度陣列
assign sound_length[0] = 20'd10121; // 音效0長度
assign sound_length[1] = 20'd6385; // 音效1長度
assign sound_length[2] = 20'h00000; // 音效2長度
assign sound_length[3] = 20'h00000; // 音效3長度
assign sound_length[4] = 20'h00000; // 音效4長度
assign sound_length[5] = 20'h00000; // 音效5長度
assign sound_length[6] = 20'h00000; // 音效6長度
assign sound_length[7] = 20'h00000; // 音效7長度
assign sound_length[8] = 20'h00000; // 音效8長度
assign sound_length[9] = 20'h00000; // 音效9長度
assign sound_length[10] = 20'h00000; // 音效10長度
assign sound_length[11] = 20'h00000; // 音效11長度
assign sound_length[12] = 20'h00000; // 音效12長度
assign sound_length[13] = 20'h00000; // 音效13長度
assign sound_length[14] = 20'h00000; // 音效14長度
assign sound_length[15] = 20'h00000; // 音效15長度


// ---------- Finite State Machine ---------- //
reg [5:0] state_r;
reg [5:0] state_w; 
always_comb begin
    state_w = state_r; // 預設情況下，保持當前狀態
    case (state_r)
        S_IDLE: begin
            state_w = S_I2C; // 當狀態為S_IDLE時，轉移到S_I2C
        end
        S_I2C: begin
            if (i2c_finished) begin
                state_w = S_PLAY; // 當I2C初始化完成時，轉移到S_PLAY
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


// ---------- Registers & Wires ---------- //
reg [19:0] time_r; // 用於計時的寄存器
wire [19:0] time_w; // 用於計時的線網
assign time_w = (state_r == S_PLAY) ? time_r + 1 : // 當狀態為S_PLAY時，計時器增加
                (state_r == S_PAUSE) ? time_r : // 當狀態為S_PAUSE時，保持計時器不變
                0; // 其他情況下，計時器歸零

reg [15:0] time_in_sound_pos_cycle; // 用於計算音效循環中的時間, should be within 0 ~ 1563
reg [15:0] time_in_sound_neg_cycle; // 用於計算音效循環中的時間, should be within 0 ~ 1563


localparam MAX_PRESSED_COUNT = 256; // 最大音效循環數量
reg [23:0] pressed_data_r [0:MAX_PRESSED_COUNT-1]; // 前4個bits是音效ID，後20個bits是音效開始時間
wire [23:0] pressed_data_w [0:MAX_PRESSED_COUNT-1];
genvar i;
generate
    for (i = 0; i < MAX_PRESSED_COUNT; i++) begin : assign_loop
        assign pressed_data_w[i] = 
            (state_r == S_PLAY && (i_sw_16_pos || i_sw_16_neg) && i == pressed_count_r) ? {4'b0000, time_r} :
            (state_r == S_PLAY && (i_sw_15_pos || i_sw_15_neg) && i == pressed_count_r) ? {4'b1111, time_r} :
            (state_r == S_PLAY && (i_sw_14_pos || i_sw_14_neg) && i == pressed_count_r) ? {4'b1110, time_r} :
            (state_r == S_PLAY && (i_sw_13_pos || i_sw_13_neg) && i == pressed_count_r) ? {4'b1101, time_r} :
            (state_r == S_PLAY && (i_sw_12_pos || i_sw_12_neg) && i == pressed_count_r) ? {4'b1100, time_r} :
            (state_r == S_PLAY && (i_sw_11_pos || i_sw_11_neg) && i == pressed_count_r) ? {4'b1011, time_r} :
            (state_r == S_PLAY && (i_sw_10_pos || i_sw_10_neg) && i == pressed_count_r) ? {4'b1010, time_r} :
            (state_r == S_PLAY && (i_sw_9_pos || i_sw_9_neg) && i == pressed_count_r) ? {4'b1001, time_r} :
            pressed_data_r[i];
    end
endgenerate


reg [15:0] pressed_count_r; // 記錄已按下的音效數量
wire [15:0] pressed_count_w;
assign pressed_count_w = (state_r == S_PLAY && (i_sw_16_pos || i_sw_16_neg || i_sw_15_pos || i_sw_15_neg || i_sw_14_pos || i_sw_14_neg || i_sw_13_pos || i_sw_13_neg || i_sw_12_pos || i_sw_12_neg || i_sw_11_pos || i_sw_11_neg || i_sw_10_pos || i_sw_10_neg || i_sw_9_pos || i_sw_9_neg) ) ? pressed_count_r + 1 :
                            pressed_count_r; // 其他情況下，保持已按下的音效數量不變
reg enable16_r, enable15_r, enable14_r, enable13_r, enable12_r, enable11_r, enable10_r, enable9_r; // 用於控制音效開關

wire play_what_is_stored;
assign play_what_is_stored = (state_r == S_PLAY && i_slide_switches[17]); // 當狀態為S_PLAY且"滑動開關#17"被打開時，播放已存儲的音效

reg [15:0] dac_data_r; // 用於DAC的數據寄存器
assign dac_data = dac_data_r; // 將DAC數據寄存器的值輸出到DAC
wire should_read_SRAM; // 用於判斷是否需要讀取SRAM
assign should_read_SRAM = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle <= pressed_count_r
    && time_r >= pressed_data_r[time_in_sound_pos_cycle-1][19:0] // 檢查當前時間是否大於等於音效開始時間
    && time_r < pressed_data_r[time_in_sound_pos_cycle-1][19:0] + sound_length[pressed_data_r[time_in_sound_pos_cycle-1][23:20]] // 檢查當前時間是否小於音效結束時間
);
assign should_calculate_wave_16 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 116
    && enable16_r
);
assign should_calculate_wave_15 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 115
    && enable15_r
);
assign should_calculate_wave_14 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 114
    && enable14_r
);
assign should_calculate_wave_13 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 113
    && enable13_r
);
assign should_calculate_wave_12 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 112
    && enable12_r
);
assign should_calculate_wave_11 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 111
    && enable11_r
);
assign should_calculate_wave_10 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 110
    && enable10_r
);
assign should_calculate_wave_9 = (
    state_r == S_PLAY
    && i_AUD_DACLRCK
    && time_in_sound_pos_cycle == 109
    && enable9_r
);
assign o_SRAM_ADDR = (play_what_is_stored) ? time_r :
                     sound_addr[pressed_data_r[time_in_sound_pos_cycle-1][23:20]] 
                     + (time_r - pressed_data_r[time_in_sound_pos_cycle-1][19:0]); // 當需要讀取SRAM時，設置SRAM地址為對應音效的地址，否則設置為0
wire [15:0] tmp16 = time_r / 122;
wire [15:0] tmp15 = time_r / 109;
wire [15:0] tmp14 = time_r / 97;
wire [15:0] tmp13 = time_r / 92;
wire [15:0] tmp12 = time_r / 82;
wire [15:0] tmp11 = time_r / 73;
wire [15:0] tmp10 = time_r / 65;
wire [15:0] tmp9 = time_r / 61;
wire [15:0] dac_data_w; // 用於DAC的數據線網
assign dac_data_w = (state_r == S_PLAY && time_in_sound_neg_cycle < 3) ? 
                        (play_what_is_stored) ? 
                            io_SRAM_DQ
                        : dac_data_r + ( (should_calculate_wave_16 && tmp16[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_15 && tmp15[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_14 && tmp14[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_13 && tmp13[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_12 && tmp12[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_11 && tmp11[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_10 && tmp10[0]) ? 600 : 0)
                                    + ( (should_calculate_wave_9 && tmp9[0]) ? 600 : 0)
                    : 0; // 當狀態為S_PLAY時，DAC數據增加，否則保持不變




// ---------- Other Assignments ---------- //
assign i2c_start = (state_r == S_I2C) ? 1'b1 : 1'b0; // 當狀態為S_I2C時，開始I2C初始化

// Seven Segment Display
assign o_hex76 = {2'b00, time_r[19:15]}; // 顯示計時器的整數秒
assign o_hex54 = pressed_count_r;  // TODO: 需要根據實際需求填充
assign o_hex32 = dac_data_r[13:7];  // TODO: 需要根據實際需求填充
assign o_hex10 = dac_data_r[6:0];  // TODO: 需要根據實際需求填充

// LED Indicators
assign o_ledg = (state_r == S_IDLE) ? 9'b000000001 : // 當狀態為S_IDLE時，綠色LED亮起
                (state_r == S_I2C) ? 9'b000000010 : // 當狀態為S_I2C時，綠色LED亮起
                (state_r == S_PLAY) ? 9'b000000100 : // 當狀態為S_PLAY時，綠色LED亮起
                (state_r == S_PAUSE) ? 9'b000001000 : // 當狀態為S_PAUSE時，綠色LED亮起
                9'b000000000; // 其他情況下，所有LED熄滅



// ---------- Sequential Logic ---------- //
always_ff @(posedge i_clk or negedge i_rst_n) begin //i_AUD_BCLK
	if (!i_rst_n) begin
		state_r <= S_IDLE; // 當復位時，狀態設為S_IDLE
        pressed_count_r <= 0; // 當復位時，已按下的音效數量歸零
        time_in_sound_pos_cycle <= 0; // 當復位時，音效循環時間歸零
        time_in_sound_neg_cycle <= 0; // 當復位時，音效循環時間歸零
        dac_data_r <= 0; // 當復位時，DAC數據寄存器歸零
        for (int i = 0; i < MAX_PRESSED_COUNT; i++) begin
            pressed_data_r[i] <= 0; // 當復位時，清空已按下的音效數據
        end
        enable16_r <= 0;
        enable15_r <= 0;
        enable14_r <= 0;
        enable13_r <= 0;
        enable12_r <= 0;
        enable11_r <= 0;
        enable10_r <= 0;
        enable9_r <= 0; // 當復位時，所有音效開關設為關閉
	end
	else begin
		state_r <= state_w;
        pressed_count_r <= pressed_count_w; // 更新已按下的音效數量
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
        enable16_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b0000 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_16_pos || i_sw_16_neg))
                    )   ? ~enable16_r : enable16_r;
        enable15_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1111 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_15_pos || i_sw_15_neg))
                    )   ? ~enable15_r : enable15_r;
        enable14_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1110 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_14_pos || i_sw_14_neg))
                    )   ? ~enable14_r : enable14_r;
        enable13_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1101 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_13_pos || i_sw_13_neg))
                    )   ? ~enable13_r : enable13_r;
        enable12_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1100 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_12_pos || i_sw_12_neg))
                    )   ? ~enable12_r : enable12_r;
        enable11_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1011 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_11_pos || i_sw_11_neg))
                    )   ? ~enable11_r : enable11_r;
        enable10_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1010 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_10_pos || i_sw_10_neg))
                    )   ? ~enable10_r : enable10_r;
        enable9_r <= (time_in_sound_pos_cycle > 0 && time_in_sound_pos_cycle <= pressed_count_r
                        && pressed_data_r[time_in_sound_pos_cycle-1][23:20] == 4'b1001 
                        && time_r == pressed_data_r[time_in_sound_pos_cycle-1][19:0] 
                        || (state_r == S_PLAY && (i_sw_9_pos || i_sw_9_neg))
                    )   ? ~enable9_r : enable9_r;
                        
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
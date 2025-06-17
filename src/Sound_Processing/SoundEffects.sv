import sound_pkg::*;

module SoundEffects(
    input         i_clk,      // 時鐘信號
    input         i_rst_n,    // 復位信號，低有效

    input  [32:0] i_data, // 33 bits
    input  [19:0] time_r, // 20 bits
    input         play_what_is_stored,   // 時鐘信號

	input signed [15:0] i_SRAM_DQ,
    output [19:0] o_SRAM_ADDR,
    
    output [15:0] o_sound_effects // 16 bits
);



wire [4:0] BtnID = i_data[24:20]; // 從i_data中提取按鈕ID
wire [19:0] sound_start_addr = sound_pkg::SOUND_ADDR[BtnID]; // 從sound_pkg中獲取對應按鈕的音效地址
wire [19:0] sound_length = sound_pkg::SOUND_LENGTH[BtnID]; // 從sound_pkg中獲取對應按鈕的音效長度

wire [19:0] addr = sound_start_addr + time_r - i_data[19:0];

wire [19:0] o_SRAM_ADDR_w = (play_what_is_stored) ? time_r : addr; // 如果play_what_is_stored為1，則輸出時間，否則輸出0
reg [19:0] o_SRAM_ADDR_r;
assign o_SRAM_ADDR = o_SRAM_ADDR_r;

wire [19:0] end_time = i_data[19:0] + sound_length;

wire should_output_something_w = (i_data != 0) && ((i_data[32] == 0)) && (time_r >= i_data[19:0]) && (time_r[18:0] < end_time);
reg should_output_something_r;

wire [1:0] volume_w = i_data[28:27]; // 從i_data中提取音量信息
reg [1:0] volume_r; // 音量寄存器

assign o_sound_effects = (play_what_is_stored || should_output_something_r) ? 
                            i_SRAM_DQ >>> volume_r : 0; // 如果play_what_is_stored為1，則輸出SRAM數據，否則輸出0 

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_SRAM_ADDR_r <= 0;
        should_output_something_r <= 0; // 初始化should_output_something_r為0
        volume_r <= 0; // 初始化音量寄存器
    end else begin
        o_SRAM_ADDR_r <= o_SRAM_ADDR_w; // 更新SRAM地址寄存器
        should_output_something_r <= should_output_something_w; // 更新should_output_something_r
        if (play_what_is_stored) begin
            volume_r <= 0; // 如果play_what_is_stored為1，則音量設置為0
        end else begin
            volume_r <= volume_w; // 否則，使用i_data中的音量信息
        end
    end
end

endmodule
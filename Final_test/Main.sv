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
    input i_AUD_BCLK,
    input i_AUD_DACLRCK, //這個是為了在DAC為了在右聲道(=1)的時候整理音訊
    
    //SRAM interface

    //SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
    

);

//以下為copilot生成的程式碼，請確認是否符合需求
Memory memory0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_AUD_DACLRCK(i_AUD_DACLRCK),
    
    //播放的模式 or 編輯模式
    .i_mode(), 
    
    //提取音效
    .i_track_type(), 
    .o_track_data(), //提取該音效 
    
    //存入音樂
    .i_data(),
    .i_addr(),
    
    //SRAM訊號，Main.sv直接接就好
    .o_SRAM_ADDR(o_SRAM_ADDR),
    .io_SRAM_DQ(io_SRAM_DQ),
    .o_SRAM_WE_N(o_SRAM_WE_N),
    .o_SRAM_CE_N(o_SRAM_CE_N),
    .o_SRAM_OE_N(o_SRAM_OE_N),
    .o_SRAM_LB_N(o_SRAM_LB_N),
    .o_SRAM_UB_N(o_SRAM_UB_N)
);

Merge merge0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_AUD_DACLRCK(i_AUD_DACLRCK), //這個是為了在DAC為了在右聲道(=1)的時候整理音訊
    
    .i_merge_mode(), //合併模式
    .i_data(), //輸入資料
    .o_data() //輸出資料
);

endmodule
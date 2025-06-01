//-------------------------------------
// 關於Memory Module: 
//-------------------------------------
    /*
    1.負責與SRAM直接對接
    2.在i_mode為編輯模式時，將i_data存入SRAM的i_addr地址 
    3.在i_mode為播放模式時，不會寫入SRAM
    4.只要接收到i_track_type的音效編號，便會提取SRAM中對應的音效資料到o_track_data
    5.因為按下i_track的時候就要輸出一秒的音訊，這個要怎麼作要想一下
    */


module Memory(
    input i_clk,
    input i_rst_n,
    input i_AUD_DACLRCK, //這個是為了在DAC為了在右聲道(=1)的時候整理音訊
    
//播放的模式 or 編輯模式
    input i_mode,               
    
//提取音效
    input  [15:0] i_track_type, //支援16種音效
    output [15:0] o_track_data, //提取該音效 

//存入音樂
    input  [15:0] i_data, //存入音效
    input  [20:0] i_addr, //存入音效的地址(或是整首曲子進行的位置給予提取音效做為參考但也不一定需要)

//SRAM訊號，Main.sv直接接就好
    output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N
);

parameter MODE_EDIT = 1; //編輯模式
parameter MODE_PLAY = 0; //播放模式

parameter SOUND_LEN = 15'h7FA6; //這是一秒的長度，一個音效如果一秒，總共存32678個資料







endmodule
//-------------------------------------
// 關於Merge Module: 
//-------------------------------------
    /*
    1.
    2.
    3.
    4.
    5.
    */


module Merge(
    input i_clk,
    input i_rst_n,
    input i_AUD_DACLRCK, //這個是為了在DAC為了在右聲道(=1)的時候整理音訊

    input  [1:0]  i_merge_mode,
    input  [15:0] i_data,
    output [15:0] o_data
);

parameter MODE_AVG = 2'b00; 
parameter MODE_SCALE = 2'b01; 
parameter MODE_SOFT  = 2'b10;

logic [19:0] data_r, data_w;    //先留住overflow的空間，因為有可能會溢出
logic [3:0] number_of_data_r;   //用來計算有效的資料數量，之後用來做平均用的
logic [3:0] number_of_data_w;



assign o_data = data_r[19:4]; //只取高16位，低4位用來避免溢出

always_comb begin
    if (i_data != 16'b0) data_w = data_r + i_data; //將輸入的資料加到data_r上
    else data_w = data_r; //如果沒有輸入資料，則保持原狀
end



/*TODO: 這裡要加上i_merge_mode的判斷
always_comb begin
    case (i_merge_mode)
        MODE_AVG: begin

        end
        MODE_SCALE: begin
            //縮放處理，這裡假設縮放因子為2
            data_w = data_r >> 1; //簡單的右移一位，實際上需要根據縮放因子調整
        end
        MODE_SOFT: begin
            //軟化處理，這裡假設軟化係數為0.5
            data_w = data_r >> 1; //簡單的右移一位，實際上需要根據軟化係數調整
        end
        default: begin
            data_w = data_r; //默認情況下保持原狀
        end
    endcase
end
*/

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        data_r <= 16'b0;
    end else begin
        data_r <= data_w;
    end
end

endmodule
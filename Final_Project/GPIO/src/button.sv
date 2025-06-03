module Button(
    input i_clk,
    input i_rst_n,
    input i_GPIO_BTN,
    output o_LED,
    output [6:0] o_count
);



logic LED_r, LED_w;
logic [6:0] count_r, count_w;

assign o_LED = LED_r;
assign o_count = count_r;


always_comb begin
    if(i_GPIO_BTN == 1'b1 && i_GPIO_BTN != LED_r) begin
        count_w = count_r + 1; //按鈕狀態改變時，計數器加1
    end 
    else begin
        count_w = count_r; //按鈕狀態未改變時，計數器保持不變
    end
end

always_comb begin
    if (i_GPIO_BTN == 1'b1) //按下按鈕時
        LED_w = 1'b1;
    else //未按下按鈕時
        LED_w = 1'b0; //LED熄滅
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        LED_r <= 1'b0;
        count_r <= 7'b0; //初始化LED和計數器 
    end 
    else begin
        LED_r <= LED_w; //將寫入的值賦給讀取的值
        count_r <= count_w; //將寫入的計數器值賦給讀取的計數器值
    end
end

endmodule
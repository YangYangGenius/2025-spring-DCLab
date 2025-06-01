module Button(
    input i_clk,
    input i_rst_n,
    input i_GPIO_BTN,
    output o_LED
);

logic LED_r, LED_w;

assign o_LED = LED_r;

always_comb begin
    if (i_GPIO_BTN == 1'b0) //按下按鈕時
        LED_w = 1'b1;
    else //未按下按鈕時
        LED_w = 1'b0; //LED熄滅
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        LED_r <= 1'b0; 
    end 
    else begin
        LED_r <= LED_w; //將寫入的值賦給讀取的值
    end
end

endmodule
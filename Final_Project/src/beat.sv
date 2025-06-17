module Beat(
    input i_clk,
    input i_rst_n,
    input[19:0] i_time, //從main裡面來的時間
    //19~15約是32秒

    output [6:0] o_hex3,
    output [6:0] o_hex2,
    output [6:0] o_hex1,
    output [6:0] o_hex0
);
// ---------- Local Parameters ---------- //
    
    localparam B0 = 7'b1111111; //沒東西
    localparam B1 = 7'b1111110; //上
    localparam B2 = 7'b1111000; //上右
    localparam B3 = 7'b1110000; //上右下 
    localparam B4 = 7'b1000000; //圈
    localparam B8 = 7'b0000000; //
    localparam BL = 7'b0111111; 


    localparam BEAT_SECOND = 15; //第15位元是兩秒一周期
    localparam BEAT_LOCATION = 13; // 第13位元，一秒內會出現切換4次
    localparam BEAT_QUARTER_LOCATION = 11; // 第10位元，一秒內會切換16次

    localparam S_H3 = 2'd3;
    localparam S_H2 = 2'd2;
    localparam S_H1 = 2'd1;
    localparam S_H0 = 2'd0;

    localparam S_CU = 2'd0;
    localparam S_CR = 2'd1;
    localparam S_CD = 2'd2;
    localparam S_CL = 2'd3;

// ---------- Internal Signals ---------- //

    logic switch_r, switch_w;
    logic circle_r, circle_w;
    logic [3:0] HEX_counter_r, HEX_counter_w; 
    logic [3:0] C_counter_r, C_counter_w; 
    wire switch, circle;

// ---------- Wire Assignments ---------- //

    assign switch_w = i_time[BEAT_LOCATION]; 
    assign circle_w = i_time[BEAT_QUARTER_LOCATION]; 

    assign switch = (i_time[BEAT_LOCATION] != switch_r)? 1:0;
    assign circle = (i_time[BEAT_QUARTER_LOCATION] != circle_r)? 1:0;

// ---------- Seven Segment Display ---------- //

    // HEX_counter_r的值對應到七段顯示器的輸出
    assign o_hex3 =  (HEX_counter_r == S_H3) ? B8 : B0;
    assign o_hex2 =  (HEX_counter_r == S_H2) ? BL : B0;
    assign o_hex1 =  (HEX_counter_r == S_H1) ? BL: B0;
    assign o_hex0 =  (HEX_counter_r == S_H0) ? BL: B0;
    /*
    assign o_hex3 = (HEX_counter_r < S_H3) ? B4 :
                    (C_counter_r == S_CU) ? B1 :
                    (C_counter_r == S_CL) ? B2 :
                    (C_counter_r == S_CD) ? B3 : B4;

    assign o_hex2 = (HEX_counter_r > S_H2) ? B0 :
                    (HEX_counter_r < S_H2) ? B4 :
                    (C_counter_r == S_CU) ? B1 :
                    (C_counter_r == S_CL) ? B2 :
                    (C_counter_r == S_CD) ? B3 : B4;

    assign o_hex1 = (HEX_counter_r > S_H1) ? B0 :
                    (HEX_counter_r < S_H1) ? B4 :
                    (C_counter_r == S_CU) ? B1 :
                    (C_counter_r == S_CL) ? B2 :
                    (C_counter_r == S_CD) ? B3 : B4;   
    
    assign o_hex0 = (HEX_counter_r > S_H0) ? B0 :
                    (C_counter_r == S_CU) ? B1 :
                    (C_counter_r == S_CL) ? B2 :
                    (C_counter_r == S_CD) ? B3 : B4; 
    */                    

// ---------- Combinational Logic ---------- //

    always_comb begin
        if(switch && HEX_counter_r == 2'b00) HEX_counter_w = S_H3; // 如果switch為1且HEX_counter_r為3，則重置HEX_counter_w
        else if(switch) HEX_counter_w = HEX_counter_r - 1; // 否則HEX_counter_w減1 
        else HEX_counter_w = HEX_counter_r; // 否則保持不變
    end

    always_comb begin
        if(circle && C_counter_r == 2'b11) C_counter_w = 0; // 如果circle為1且C_counter_r為3，則重置C_counter_w
        else if(circle) C_counter_w = C_counter_r + 1; // 否則C_counter_w加1 
        else C_counter_w = C_counter_r; // 否則保持不變
    end

// ---------- Sequential Logic ---------- //

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            switch_r <= 1'b0;
            circle_r <= 1'b0;
            HEX_counter_r <= 2'b11;
            C_counter_r <= 2'b00;
        end else begin
            switch_r <= switch_w;
            circle_r <= circle_w;
            HEX_counter_r <= HEX_counter_w;
            C_counter_r <= C_counter_w;
        end
    end

endmodule
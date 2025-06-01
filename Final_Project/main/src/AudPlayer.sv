/*
關於AudPlayer的說明(2025.05.23)：
1.只會在左聲道輸出音訊資料，右聲道不會有任何音訊資料輸出。
2.只有在state=LEFT(此時i_daclrck已經維持左聲道一周期)的第一個時脈週期會讀取音訊資料
3.其他時間都不會讀取聲音資料
4.o_aud_dacdat=0 一直維持0的話就沒有聲音
*/


module AudPlayer (
    input i_rst_n,
    input i_bclk,   
    input i_daclrck,         // 0 for left channel, 1 for right channel
    input [15:0] i_dac_data, // 聲音資料輸入
    output o_aud_dacdat      // 聲音資料輸出
);

//FSM counter
localparam IDLE = 2'b00;
localparam LEFT = 2'b01;
localparam WAIT = 2'b11;
localparam COUNT = 4'd15;

logic [1:0] state_r, state_w;
logic [3:0] counter_r, counter_w;

//output
logic[15:0] output_r, output_w;
assign o_aud_dacdat = output_w[15];

//FSM
always_comb begin
    state_w = state_r;
    case (state_r)
        IDLE: begin
            if (!i_daclrck) begin
                state_w = LEFT;
            end
        end

        LEFT: begin
            if (counter_r == COUNT) begin
                state_w = WAIT;
            end
        end

        WAIT: begin
            if (i_daclrck) begin
                state_w = IDLE;
            end
        end

        default: begin
            state_w = IDLE;
        end
    endcase
end

//counter
always_comb begin
    counter_w = counter_r;
    if (state_r == LEFT && counter_r <= COUNT) begin
            counter_w = counter_r + 1'b1;
    end
    else begin
        counter_w = 4'b0000;
    end
end

//output logic
always_comb begin
    output_w = 16'b0;
    if(state_r == LEFT && counter_r == 0) begin
        output_w = i_dac_data; //在LEFT第一個cycle時讀取數據(只要i_dac_data等於0那就不會有任何聲音了)
    end
    else begin 
        output_w = output_r;
    end
end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= IDLE;
        counter_r <= 4'b0000;
        output_r <= 1'b0;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        output_r <= output_w << 1;
    end
end
   
endmodule

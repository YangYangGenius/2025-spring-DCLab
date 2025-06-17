module SineLUT (
    output reg [15:0] sine_table [0:31]
);
    initial begin
        sine_table[0] = 16'h0000;
        sine_table[1] = 16'h0324;
        sine_table[2] = 16'h0646;
        sine_table[3] = 16'h0964;
        sine_table[4] = 16'h0c7c;
        sine_table[5] = 16'h0f8d;
        sine_table[6] = 16'h1294;
        sine_table[7] = 16'h1590;
        sine_table[8] = 16'h187e;
        sine_table[9] = 16'h1b5d;
        sine_table[10] = 16'h1e2b;
        sine_table[11] = 16'h20e7;
        sine_table[12] = 16'h238e;
        sine_table[13] = 16'h2620;
        sine_table[14] = 16'h289a;
        sine_table[15] = 16'h2afb;
        sine_table[16] = 16'h2d41;
        sine_table[17] = 16'h2f6c;
        sine_table[18] = 16'h3179;
        sine_table[19] = 16'h3368;
        sine_table[20] = 16'h3537;
        sine_table[21] = 16'h36e5;
        sine_table[22] = 16'h3871;
        sine_table[23] = 16'h39db;
        sine_table[24] = 16'h3b21;
        sine_table[25] = 16'h3c42;
        sine_table[26] = 16'h3d3f;
        sine_table[27] = 16'h3e15;
        sine_table[28] = 16'h3ec5;
        sine_table[29] = 16'h3f4f;
        sine_table[30] = 16'h3fb1;
        sine_table[31] = 16'h3fec;

    end
    
endmodule

module SinWave(
    input         i_clk,   // 時鐘信號
    input         i_rst_n, // 重置信號，低電平有效
    input  [15:0] tp, // time_in_sound_pos_cycle


    input  [32:0] i_data,  // 33 bits
    input  [19:0] time_r, // 20 bits
    input  [31:0] theta [0:24],
    
    output [15:0] o_sin // 16 bits
);


// ---------- Local Parameters ---------- //
localparam AMPLITUDE = 3000;

// ---------- Registers & Wires ---------- //
reg enable_r [0:3][0:3][0:24];

wire [15:0] tp1 = tp - 1;

reg [15:0] o_sin_w, o_sin_r;
assign o_sin = o_sin_r; // 將輸出信號連接到o_sin
reg [4:0] LUT_index, LUT_index_inv;
reg [15:0] o_sin_w_temp;
reg [31:0] multiply_result; // 用於存儲乘法結果
reg [4:0] start; 
reg [15:0] Sine_LUT [0:31]; // 正弦查找表

SineLUT LUT_0(
    .sine_table(Sine_LUT)
);

always @(*) begin
    o_sin_w = o_sin_r;
    if(tp1 < 512 && enable_r[tp1[8:7]][tp1[6:5]][tp1[4:0]]) begin
        start = 14 + tp1[6:5];
        LUT_index = theta[tp1[4:0]][(start-2)-:5];
        LUT_index_inv = 5'd31 - LUT_index;
        if(theta[tp1[4:0]][start-:2] == 2'd0) begin
            o_sin_w_temp = Sine_LUT[LUT_index];
            multiply_result = (o_sin_w_temp + 16'h4000)* AMPLITUDE;
        end
        else if(theta[tp1[4:0]][start-:2] == 2'd1) begin
            o_sin_w_temp = Sine_LUT[LUT_index_inv];
            multiply_result = (o_sin_w_temp + 16'h4000)* AMPLITUDE;
        end
        else if(theta[tp1[4:0]][start-:2] == 2'd2) begin
            o_sin_w_temp = Sine_LUT[LUT_index];
            multiply_result = (16'h4000 - o_sin_w_temp)* AMPLITUDE;
        end
        else if(theta[tp1[4:0]][start-:2] == 2'd3) begin
            o_sin_w_temp = Sine_LUT[LUT_index_inv];
            multiply_result = (16'h4000 - o_sin_w_temp)* AMPLITUDE;
        end
        o_sin_w = multiply_result[31:16];
        o_sin_w = o_sin_w >> tp1[8:7];
    end
    else begin
        o_sin_w = 0;
    end
end
// wire [31:0] count_based_on_freq [0:24]; // 用於計算基於頻率的計數值
// genvar j;
// generate
//     for (j = 0; j < 25; j++) begin : freq_loop
//         assign count_based_on_freq[j] = time_r * freq_pkg::FREQ[j]; // 計算基於頻率的計數值
//     end
// endgenerate

localparam WaveType_sin = 2'b11;
wire isWave = i_data[32];
wire OnOff = i_data[31];
wire [1:0] WaveType = i_data[30:29];
wire [1:0] Volume = i_data[28:27];
wire [1:0] Octave = i_data[26:25];
wire [4:0] BtnID = i_data[24:20];

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        // 初始化所有使能信號為0
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                for (int k = 0; k < 25; k++) begin
                    enable_r[i][j][k] <= 0;
                end
            end
        end
        o_sin_r <= 0; // 初始化輸出為0
    end else begin
        // 根據輸入數據和時間計算使能信號
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                for (int k = 0; k < 25; k++) begin
                    enable_r[i][j][k] <= (isWave == 1'b1 && WaveType == WaveType_sin && i_data[19:0] == time_r 
                                    && Volume == i && Octave == j && BtnID == k) ? 
                                    OnOff : enable_r[i][j][k];
                end
            end
        end
        o_sin_r <= o_sin_w; // 更新輸出
    end

end

endmodule
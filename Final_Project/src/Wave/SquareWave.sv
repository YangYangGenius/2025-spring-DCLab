module SquareWave(
    input         i_clk,   // 時鐘信號
    input         i_rst_n, // 重置信號，低電平有效
    input  [15:0] tp, // time_in_sound_pos_cycle


    input  [32:0] i_data,  // 33 bits
    input  [19:0] time_r, // 20 bits
    input  [31:0] theta [0:24],
    
    output [15:0] o_square // 16 bits
);


// ---------- Local Parameters ---------- //
localparam AMPLITUDE = 1000;
// ---------- Registers & Wires ---------- //
reg enable_r [0:3][0:3][0:24];

wire [15:0] tp1 = tp - 1;

reg [15:0] o_square_r;
assign o_square = o_square_r; // 將輸出信號連接到o_square
wire [15:0] o_square_w;
assign o_square_w = (tp1 < 512 && enable_r[tp1[8:7]][tp1[6:5]][tp1[4:0]] && theta[tp1[4:0]][14+tp1[6:5]]) ? AMPLITUDE >> (tp1[8:7]) : 0; // 根據使能信號決定輸出值

// wire [31:0] count_based_on_freq [0:24]; // 用於計算基於頻率的計數值
// genvar j;
// generate
//     for (j = 0; j < 25; j++) begin : freq_loop
//         assign count_based_on_freq[j] = time_r * freq_pkg::FREQ[j]; // 計算基於頻率的計數值
//     end
// endgenerate

localparam WaveType_SQUARE = 2'b00;
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
        o_square_r <= 0; // 初始化輸出為0
    end else begin
        // 根據輸入數據和時間計算使能信號
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                for (int k = 0; k < 25; k++) begin
                    enable_r[i][j][k] <= (isWave == 1'b1 && WaveType == WaveType_SQUARE && i_data[19:0] == time_r 
                                    && Volume == i && Octave == j && BtnID == k) ? 
                                    OnOff : enable_r[i][j][k];
                end
            end
        end
        o_square_r <= o_square_w; // 更新輸出
    end

end

endmodule
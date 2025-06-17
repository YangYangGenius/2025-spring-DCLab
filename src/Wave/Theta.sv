import freq_pkg::*;

module Theta(
    input  [19:0] time_r, // 20 bits
    output [31:0] o_theta [0:24] // 32 bits x 25
);

genvar BtnID;
generate
    for (BtnID = 0; BtnID < 25; BtnID++) begin : freq_loop
        assign o_theta[BtnID] = time_r * freq_pkg::FREQ[BtnID]; // 計算基於頻率的計數值
    end
endgenerate

endmodule
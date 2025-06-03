module AudRecorder (
    input i_rst_n,
    input i_clk,
    input i_lrc, // mic only right channel, so only need to handle when i_lrc is high
    input i_start,
    input i_stop,
    input i_data, // i2s data
    output [19:0] o_address, // total 2^20 words by 16 bits can be saved
    output [15:0] o_data,
    output [19:0] o_stop_address,
    output o_done,
    output [1:0] o_state // debug purpose
);
endmodule
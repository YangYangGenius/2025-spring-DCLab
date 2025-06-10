module AudPlayer (
    input i_rst_n,
    input i_bclk,
    input i_daclrck, // 0 for left channel, 1 for right channel
    input i_en,
    input [15:0] i_dac_data,
    output o_aud_dacdat
);
   
endmodule

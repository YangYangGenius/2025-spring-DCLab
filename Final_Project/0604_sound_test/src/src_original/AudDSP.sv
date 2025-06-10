module AudDSP (
    input i_rst_n,
    input i_clk,
    input i_start, // start signal, sent by the controller, not a button press
    input i_pause, // pause signal, press to pause, press again to resume
    input [2:0] i_speed,
    input i_is_slow,
    input i_slow_mode,
    input i_daclrck,               // prepare data when low
    input signed [15:0] i_sram_data,
    input [19:0] i_sram_stop_addr, // the last address to read from SRAM
    output signed [15:0] o_dac_data,
    output o_en,                   // enable signal for AudPlayer, !i_daclrck
    output o_is_pause,
    output [19:0] o_sram_addr
);
    
endmodule
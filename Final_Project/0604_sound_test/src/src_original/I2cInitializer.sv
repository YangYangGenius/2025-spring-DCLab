module I2cInitializer (
    input i_rst_n,
    input i_clk,
    input i_start,
    /*------------------------------------------- Testbench use only -------------------------------------------*/
        // output [3:0] o_bit_counter, // testbench use only
        // output [1:0] o_byte_counter, // testbench use only
        // output [3:0] o_command_counter, // testbench use only
    output o_finished,
    output o_sclk,
    inout io_sdat,
    output o_oen // true for io_sdat output, false for input
);




endmodule
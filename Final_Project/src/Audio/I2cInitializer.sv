
module I2cInitializer (
    input i_rst_n,
    input i_clk,
    input i_start,
    output o_finished,
    output o_sclk,
    inout io_sdat,
    output o_oen // true for io_sdat output, false for input
);

/*-------------------------------------------------- Parameters --------------------------------------------------*/
localparam COMMAND_COUNT = 10;
localparam [23:0] LEFT_LINE_IN                     = 24'b0011_0100_000_0000_0_1001_0111; // to register 0x00
localparam [23:0] RIGHT_LINE_IN                    = 24'b0011_0100_000_0001_0_1001_0111; // to register 0x01
localparam [23:0] LEFT_HEADPHONE_OUT               = 24'b0011_0100_000_0010_0_0111_1001; // to register 0x02
localparam [23:0] RIGHT_HEADPHONE_OUT              = 24'b0011_0100_000_0011_0_0111_1001; // to register 0x03
localparam [23:0] ANALOGUE_AUDIO_PATH_CONTROL      = 24'b0011_0100_000_0100_0_0001_0101; // to register 0x04
localparam [23:0] DIGITAL_AUDIO_PATH_CONTROL       = 24'b0011_0100_000_0101_0_0000_0000; // to register 0x05
localparam [23:0] POWER_DOWN_CONTROL               = 24'b0011_0100_000_0110_0_0000_0000; // to register 0x06
localparam [23:0] DIGITAL_AUDIO_INTERFACE_FORMAT   = 24'b0011_0100_000_0111_0_0100_0010; // to register 0x07
localparam [23:0] SAMPLING_CONTROL                 = 24'b0011_0100_000_1000_0_0001_1001; // to register 0x08
localparam [23:0] ACTIVE_CONTROL                   = 24'b0011_0100_000_1001_0_0000_0001; // to register 0x09

// Command RESET will NOT be sent in this module.
localparam [23:0] RESET                            = 24'b0011_0100_000_1111_0_0000_0000; // to register 0x0F

// State
localparam STATE_IDLE  = 0;
localparam STATE_S1 = 1;
localparam STATE_S2 = 2;
localparam STATE_A = 3;
localparam STATE_B = 4;
localparam STATE_C = 5;
localparam STATE_D = 6;
localparam STATE_E = 7;
localparam STATE_F = 8;
localparam STATE_F1 = 9;
localparam STATE_F2 = 10;
localparam STATE_FINISH = 11;

/*------------------------------------------------- Registers -------------------------------------------------*/
reg [3:0] state_r, state_w;
reg i_data_r, i_data_w;
reg [1:0] byte_counter_r, byte_counter_w;
reg [3:0] bit_counter_r, bit_counter_w;
reg [3:0] command_counter_r, command_counter_w;

reg [23:0] command_r, command_w;
    

/*--------------------------------------------- Output assignment ---------------------------------------------*/
assign o_oen = (state_r == STATE_D || state_r == STATE_E || state_r == STATE_F) ? 0 : 1;
assign o_sclk = (state_r == STATE_A || state_r == STATE_C || state_r == STATE_D || state_r == STATE_F) ? 0 : 1;
assign io_sdat = (
    (!o_oen) ? 1'bz :
    (state_r == STATE_C && bit_counter_r + 1 == 0) ? 0 :
    (state_r == STATE_A && byte_counter_r == 3) ? 0 :
    (state_r == STATE_S2 || state_r == STATE_F1) ? 0 :
    (state_r == STATE_A || state_r == STATE_B || state_r == STATE_C) ? command_r[23] :
    1
);  
assign o_finished = (state_r == STATE_FINISH) ? 1 : 0;

/*-------------------------------------------- Combinational logic --------------------------------------------*/
// State Transition
always @(*) begin
    state_w = state_r;
    case (state_r)
    STATE_IDLE: if (i_start) state_w = STATE_S1;
    STATE_S1: state_w = STATE_S2;
    STATE_S2: state_w = STATE_C;
    STATE_A: state_w = (byte_counter_r == 3) ? STATE_F1 : STATE_B;
    STATE_B: state_w = STATE_C;
    STATE_C: state_w = (bit_counter_r == 7) ? STATE_D : STATE_A;
    STATE_D: state_w = STATE_E;
    STATE_E: state_w = STATE_F;
    STATE_F: state_w = STATE_A;
    STATE_F1: state_w = STATE_F2;
    STATE_F2: state_w = (command_counter_r == COMMAND_COUNT) ? STATE_FINISH : STATE_S1;
    STATE_FINISH: state_w = STATE_IDLE;
    endcase
end

// Counters
always @(*) begin
    byte_counter_w = byte_counter_r;
    bit_counter_w = bit_counter_r;
    command_counter_w = command_counter_r;
    case (state_r)
    STATE_IDLE: if (i_start) command_counter_w = 0;
    STATE_S1: begin
        byte_counter_w = 0;
        bit_counter_w = 4'b1111;
    end
    STATE_C: bit_counter_w = (bit_counter_r == 7) ? 0 : bit_counter_r + 1;
    STATE_F: byte_counter_w = byte_counter_r + 1;
    STATE_F1: command_counter_w = command_counter_r + 1;
    endcase
end

// Input Data
always @(*) begin
    i_data_w <= io_sdat;
end

// Command
always @(*) begin
    command_w = command_r;
    case (state_r)
    STATE_S1: begin
        case (command_counter_r)
        0: command_w = LEFT_LINE_IN;
        1: command_w = RIGHT_LINE_IN;
        2: command_w = LEFT_HEADPHONE_OUT;
        3: command_w = RIGHT_HEADPHONE_OUT;
        4: command_w = ANALOGUE_AUDIO_PATH_CONTROL;
        5: command_w = DIGITAL_AUDIO_PATH_CONTROL;
        6: command_w = POWER_DOWN_CONTROL;
        7: command_w = DIGITAL_AUDIO_INTERFACE_FORMAT;
        8: command_w = SAMPLING_CONTROL;
        9: command_w = ACTIVE_CONTROL;
        endcase
    end
    STATE_C: if (bit_counter_r != 4'b1111) command_w = command_r << 1;
    endcase
end

/*----------------------------------------------- Sequential logic ----------------------------------------------*/
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= 0;
        i_data_r <= 0;
        byte_counter_r <= 0;
        bit_counter_r <= 0;
        command_counter_r <= 0;
        command_r <= 0;
    end 
    else begin
        state_r <= state_w;
        i_data_r <= i_data_w;
        byte_counter_r <= byte_counter_w;
        bit_counter_r <= bit_counter_w;
        command_counter_r <= command_counter_w;
        command_r <= command_w;
    end
end
endmodule
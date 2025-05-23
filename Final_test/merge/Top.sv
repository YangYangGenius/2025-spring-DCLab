module merge(
    input i_clk,
    input i_rst_n,
    input i_key_0,
    input i_key_1,
    input i_key_2,

// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,

// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
// AudPlayer 揚
	inout  i_AUD_BCLK, 		//Audio CODEC Bit-Steam Clock時鐘 	(master mode->這邊是input)
	inout  i_AUD_ADCLRCK,	//錄音		(master mode->這邊是input)
	inout  i_AUD_DACLRCK,	//播放		(master mode->這邊是input)
	input  i_AUD_ADCDAT,	//Audio CODEC ADC Data
	output o_AUD_DACDAT,		//Audio CODEC DAC Data

// SEVENDECODER (optional display)
	output [6:0] o_time,
	output [6:0] o_time_2,

// LED
	output  [3:0] o_ledg,
	output [17:0] o_ledr
);

// FSM
parameter S_IDLE = 0; 
parameter S_I2C  = 1;
parameter S_WAIT = 2
parameter S_LEFT = 3; //左播放
parameter S_RIGHT = 4; //等待
logic [1:0] state_r, state_w;

// stop control
parameter STOP_ADDR_COUNT = 20'h1FFFF; //四秒


//-------------------------------addr control-------------------------------
    logic [19:0] addr_r, addr_w;

    always_comb begin
        addr_w = addr_r;
        if (addr_r == STOP_ADDR_COUNT)                  addr_w = 20'h0;
        else if (state_r == S_LEFT && i_AUD_DACLRCK)    addr_w = addr_r + 1'b1;   
    end



//-------------------------------stop control-------------------------------
    logic stop_r, stop_w;
    always_comb begin
        if (addr_r == STOP_ADDR_COUNT) stop_w = 1'b1;
        else stop_w = 1'b0;
    end

//-------------------------------fetch control-------------------------------
    parameter MUSIC_1_BEGIN = 20'h20000;
    parameter MUSIC_1_END   = 20'h3FFFF; //四秒
    parameter MUSIC_2_BEGIN = 20'h40000;
    parameter MUSIC_2_END   = 20'h5FFFF; //四秒
    parameter MUSIC_3_BEGIN = 20'h60000;
    parameter MUSIC_3_END   = 20'h7FFFF; //四秒
    parameter MUSIC_4_BEGIN = 20'h80000;
    parameter MUSIC_4_END   = 20'h9FFFF; //四秒
    parameter NUM_MUSIC = 4;

    wire [19:0] addr_fetch;
    logic [NUM_MUSIC-1:0] music_count_r, music_count_w;

    assign addr_fetch = {music_count_r, 16'h0000} + addr_r; //取出音樂資料的地址

    always_comb begin
        if (state = S_LEFT) music_count_w = 4'h2;
        else if (state_r == S_RIGHT && music_count_r <= 4'h8) music_count_w = music_count_r + 4'h2;
        else music_count_w = music_count_r;
    end

//-------------------------------SRAM control-------------------------------

    assign o_SRAM_ADDR = addr_fetch;
    assign io_SRAM_DQ  = 16'dz; // sram_dq as output

    assign o_SRAM_WE_N = 1'b1; //SRAM_WE_N 設定目前操作模式， 0 為寫， 1 為讀 
    assign o_SRAM_CE_N = 1'b0;
    assign o_SRAM_OE_N = 1'b0;
    assign o_SRAM_LB_N = 1'b0;
    assign o_SRAM_UB_N = 1'b0;

//-------------------------------Output & Merge control-------------------------------

    //在DE2-115上， SRAM的讀取是同一個cycle，但還是建議往後延遲一個cycle
    logic [15:0] read_data_r, read_data_w;
    wire  [15:0] merge_data;
    wire  [1:0]  merge_mode;

    assign merge_mode = 2'b0;

    always_comb begin
        if (state_r == S_RIGHT && music_count_r <= 4'h8) begin
            read_data_w = io_SRAM_DQ;  
        end
        else read_data_w = 16'b0; 
    end

    Merge merge0(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_mode(merge_mode),
        .i_data(read_data_r),
        .o_data(merge_data)
    );

//-------------------------------Output monitor-------------------------------

    assign o_time = {2'b00, addr_r[19:15]};

    wire[9:0] mili_0;
    wire [14:0] a_extended;
    wire [14:0] sum;
    assign mili_0 = addr_r[14:5];
    assign a_extended = {5'b0, mili_0}; // Extend a to 15 bits by adding 5 leading zeros
    assign sum = a_extended + (a_extended << 3) + (a_extended << 4); // Multiply by 25
    assign o_time_2 = sum[14:8];

    assign o_ledg = (state_r == S_IDLE) ? 4'b1111 :
                    (state_r == S_I2C)  ? 4'b0001 : 
                    (state_r == S_WAIT) ? 4'b0010 : 
                    (state_r == S_LEFT) ? 4'b0100 : 4'b1000;

//-------------------------------I2C control-------------------------------

    // I2C control signals
    logic i2c_oen, i2c_sdat; // 助教
    wire i2c_finished; 
    logic i2c_start_r, i2c_start_w; //不用w
    //assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz; // 助教

    always_comb begin
        if (state_r == S_I2C) i2c_start_w = 1;
        else i2c_start_w = 0;
    end

    I2cInitializer init0(
        .i_rst_n(i_rst_n),
        .i_clk(i_clk_100k),
        .i_start(i2c_start_r),
        .o_finished(i2c_finished),
        .o_sclk(o_I2C_SCLK),
        .io_sdat(io_I2C_SDAT), // i2c_sdat有問題
        .o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
    );

//-------------------------------AudPlayer-------------------------------

    AudPlayer player0(
        .i_rst_n(i_rst_n),
        .i_bclk(i_AUD_BCLK),
        .i_daclrck(i_AUD_DACLRCK),			
        .i_dac_data(merge_data), 	//dac_data
        .o_aud_dacdat(o_AUD_DACDAT)
    );

//-------------------------------FSM and CLock-------------------------------

    always_comb begin
        state_w = state_r;
        case(state_r)
            S_IDLE: begin
                state_w = S_I2C;
            end
            S_I2C: begin
                if (i2c_finished) state_w = S_WAIT;
            end
            S_WAIT: begin
                if (i_key_0 && i_AUD_DACLRCK) state_w = S_RIGHT;
            end
            S_RIGHT: begin 
                if (!i_AUD_DACLRCK) state_w = S_LEFT;
            end
            S_LEFT: begin
                if (stop_r == 1'b1) state = S_WAIT;
                else if (i_AUD_DACLRCK) state_w = S_RIGHT;
            end
            default: state_w = state_r;
        endcase
        
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin //i_AUD_BCLK
        if (!i_rst_n) begin
            state_r <= S_IDLE;
            i2c_start_r <= 0;

        end
        else begin
            state_r <= state_w;
            i2c_start_r <= i2c_start_w;
            read_data_r <= read_data_w;
            music_count_r <= music_count_w;
            addr_r <= addr_w;
            stop_r <= stop_w;
            data_play_r <= data_play_w;
        end
    end

endmodule

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

localparam S_IDLE = 0;
localparam S_PAUSE = 1;
localparam S_PLAY = 2;
localparam S_RECORD = 3;

logic [1:0] state_r, state_w;
logic is_pause_r, is_pause_w;
logic is_slow_r, is_slow_w;
logic slow_mode_r, slow_mode_w;
logic [2:0] speed_r, speed_w;
logic [2:0] slow_counter_r, slow_counter_w;
logic get_data_counter_r, get_data_counter_w;
logic [19:0] addr_r, addr_w;
logic [15:0] sram_data_r, sram_data_w, sram_data_next_r, sram_data_next_w;
logic [15:0] o_data_r, o_data_w;

assign o_en = !i_daclrck;
assign o_dac_data = o_data_r;
assign o_sram_addr = addr_r;
assign o_is_pause = is_pause_r;

// state machine
always@(*) begin
    state_w = state_r;
    case(state_r)
        S_IDLE: begin
            if(i_start)         state_w = S_PAUSE;
            else                state_w = S_IDLE;
        end
        S_PAUSE: begin
            if(!is_pause_r)     state_w = S_PLAY;
            else                state_w = S_PAUSE;
        end
        S_PLAY: begin
            if(is_pause_r)      state_w = S_PAUSE;
            else if(!i_daclrck) state_w = S_PAUSE;
            else                state_w = S_PLAY;
        end
    endcase
end

// slow counter: for slow mode, getting data every {speed} cycle
always@(*) begin
    slow_counter_w = slow_counter_r;
    case(state_r)
        S_IDLE:     slow_counter_w = 0;
        S_PAUSE:    slow_counter_w = slow_counter_r;
        S_PLAY: begin
            if(is_slow_r) begin
                if(slow_counter_r > speed_r)    slow_counter_w = 0;
                else                            slow_counter_w = slow_counter_r + 1;
            end
        end
    endcase
end

// get data counter: can go to output when get_data_counter = 1
always@(*) begin
    get_data_counter_w = get_data_counter_r;
    case(state_r)
        S_IDLE:     get_data_counter_w = 0;
        S_PAUSE:    get_data_counter_w = 0;
        S_PLAY: begin
            if(get_data_counter_r < 1)  get_data_counter_w = 1;
        end
    endcase
end

// pause: toggle between S_PAUSE and S_PLAY
always@(*) begin
    is_pause_w = is_pause_r;
    case(state_r)
        S_IDLE:                 is_pause_w = 1;
        S_PAUSE: if(i_pause)    is_pause_w = 0;
        S_PLAY:  if(i_pause)    is_pause_w = 1;
    endcase
end

// slow & fast config
always@(*) begin
    is_slow_w = is_slow_r;
    slow_mode_w = slow_mode_r;
    speed_w = speed_r;
    case(state_r)
        S_IDLE: begin
            is_slow_w = 0;
            slow_mode_w = 0;
            speed_w = 0;
        end
        S_PAUSE: begin
            is_slow_w = i_is_slow;
            slow_mode_w = i_slow_mode;
            speed_w = i_speed;
        end
        S_PLAY: begin
            is_slow_w = is_slow_r;
            slow_mode_w = slow_mode_r;
            speed_w = speed_r;
        end
    endcase
end

// addr: get the next sram address of data we need
logic [20:0] temp_addr;     //temporarily store address (add 1 bit to prevent overflow)
always@(*) begin
    addr_w = addr_r;
    temp_addr = addr_r;
    case(state_r)
        S_IDLE:     temp_addr = 0;
        S_PLAY: begin
            if(is_slow_r) begin
                if(slow_counter_r == 0)     temp_addr = addr_r + 1;
            end
            else                            temp_addr = addr_r + speed_r + 1;
        end
    endcase
    if(temp_addr > i_sram_stop_addr)    addr_w = 0;
    else                                addr_w = temp_addr;
end

// i_data: get two consecutive data from sram 
always@(*) begin
    sram_data_w = sram_data_r;
    sram_data_next_w = sram_data_next_w;
    case(state_r)
        S_IDLE: begin
            sram_data_w = 0;
            sram_data_next_w = 0;
        end
        S_PAUSE: begin
            sram_data_w = sram_data_r;
            sram_data_next_w = i_sram_data;
        end
        S_PLAY: begin
            if(is_slow_r)begin          // slow
                if(slow_counter_r == 0) begin
                    sram_data_w = sram_data_next_r;
                    sram_data_next_w = i_sram_data;
                end
            end
            else begin                  // fast & normal
                sram_data_w = sram_data_next_r;
                sram_data_next_w = i_sram_data;
            end
        end
    endcase
end

// o_data: calculate the data to output to AudPlayer
logic [16:0] diff;
logic [20:0] diff_counter_prod;
logic [20:0] diff_counter_prod_div_speed;
always@(*) begin
    o_data_w = o_data_r;
    diff = 0;
    diff_counter_prod = 0;
    diff_counter_prod_div_speed = 0;
    case(state_r)
        S_IDLE:     o_data_w = 0;
        S_PLAY: begin
            if(get_data_counter_r == 1) begin
                if(is_slow_r) begin
                    if(slow_mode_r) begin
						diff = $signed(sram_data_next) - $signed(sram_data);
						diff_counter_prod = $signed(diff) * $signed({1'b0, slow_counter_r});
						diff_counter_prod_div_speed = $signed($signed(diff_counter) / $signed({1'b0, speed_r + 1}));
						o_data_w = $signed($signed(sram_data) + $signed(diff_counter_div_speed));
                    end
                    else o_data_w = sram_data;
                end
                else o_data_w = sram_data;
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= S_IDLE;
        is_pause_r <= 1;
        addr_r <= 0;
        speed_r <= 0;
        o_data_r <= 0;
        is_slow_r <= 0;
        slow_mode_r <= 0;
        sram_data_r <= 0;
        slow_counter_r <= 0;
        sram_data_next_r <= 0;
        get_data_counter_r <= 0;
    end
    else begin
        state_r <= state_w;
        is_pause_r <= is_pause_w;
        addr_r <= addr_w;
        speed_r <= speed_w;
        o_data_r <= o_data_w;
        is_slow_r <= is_slow_w;
        slow_mode_r <= slow_mode_w;
        sram_data_r <= sram_data_w;
        slow_counter_r <= slow_counter_w;
        sram_data_next_r <= sram_data_next_w;
        get_data_counter_r <= get_data_counter_w;
    end
end

endmodule
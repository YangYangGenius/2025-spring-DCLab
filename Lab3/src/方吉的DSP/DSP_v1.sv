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
localparam S_GET = 2;
localparam S_SEND = 3;

reg [1:0] state_r, state_w;
reg [3:0] slow_counter_r, slow_counter_w;
reg [1:0] get_data_counter_r, get_data_counter_w;

reg is_pause_r, is_pause_w;
reg [2:0] speed_r, speed_w;
reg is_slow_r, slow_mode_r, is_slow_w, slow_mode_w;

reg [19:0] addr_r, addr_w, mode_addr;
reg [15:0] sram_data_w, sram_data_next_w, sram_data_r, sram_data_next_r;
reg [15:0] o_data_r, o_data_w;

assign o_en = !i_daclrck;
assign o_dac_data = o_data_r;
assign o_sram_addr = addr_r;
assign o_is_pause = is_pause_r;

//state machine
always@(*) begin
	state_w = state_r;
	case(state_r)
		S_IDLE: begin
			if(i_start)			state_w = S_PAUSE;
			else				state_w = S_IDLE;
		end
		S_PAUSE: begin
			if(!is_pause_r)		state_w = S_GET;
			else				state_w = S_PAUSE;
		end
		S_GET: begin
			if(is_pause_r)		state_w = S_PAUSE;
			else begin
				if(!i_daclrck)	state_w = S_SEND;
				else			state_w = S_GET;
			end
		end
		S_SEND: begin
			if(is_pause_r)		state_w = S_PAUSE;
			else begin
				if(!i_daclrck)	state_w = S_SEND;
				else			state_w = S_GET;
			end
		end
	endcase
end

// pause: when pause button is pressed (i_pause signal), toggle between S_PAUSE and S_GET/S_SEND
always@(*) begin
	is_pause_w = is_pause_r;
	case(state_r)
		S_IDLE:		is_pause_w = 1;
		S_PAUSE:	if(i_pause)	is_pause_w = 0;
		S_GET:		if(i_pause) is_pause_w = 1;
		S_SEND:		if(i_pause) is_pause_w = 1;
	endcase
end

// slow counter: counting up from 0 until it reach the speed
always@(*) begin
	slow_counter_w = slow_counter_r;
	case(state_r)
		S_IDLE: 	slow_counter_w = 0;
		S_PAUSE: 	slow_counter_w = 0;
		S_GET:	begin
			if(is_slow_r && i_daclrck && !is_pause_r)begin
				if(slow_counter_r == speed_r) 	slow_counter_w = 0;
				else							slow_counter_w = slow_counter_r + 1;
			end
		end
		S_SEND:		slow_counter_w = 0;	
	endcase
end

// get data counter: need 2 cycles to load two consecutive SRAM data for slow mode
// the slow mode can start computing when get data counter = 3
always@(*) begin
	get_data_counter_w = get_data_counter_r;
	case(state_r)
		S_IDLE: 	get_data_counter_w = 0;
		S_PAUSE: 	get_data_counter_w = 0;
		S_SEND:		get_data_counter_w = 0;
		S_GET:		if(get_data_counter_r < 3)	get_data_counter_w = get_data_counter_r + 1;
	endcase
end

// is_slow, slow_mode, speed cannot be changed during DSP getting data (S_GET)
// is_slow, slow_mode, speed can be changed when S_PAUSE and S_SEND
always@(*) begin
	is_slow_w = is_slow_r;
	slow_mode_w = slow_mode_r;
	speed_w = speed_r;
	case(state_r)
		S_IDLE:begin
			is_slow_w = 0;
			slow_mode_w = 0;
			speed_w = 0;
		end
		S_PAUSE:begin
			is_slow_w = i_is_slow;
			slow_mode_w = i_slow_mode;
			speed_w = i_speed;
		end
		S_SEND:begin
			is_slow_w = i_is_slow;
			slow_mode_w = i_slow_mode;
			speed_w = i_speed;
		end
		S_GET:begin
			is_slow_w = is_slow_r;
			slow_mode_w = slow_mode_r;
			speed_w = speed_r;
		end
	endcase
end

// get SRAM address(normal/fast/slow)
always@(*) begin
	addr_w = addr_r;
	mode_addr = addr_r;
	case(state_r)
		S_IDLE:	mode_addr = 0;
		S_GET: begin
			if(get_data_counter_r == 0) begin
				if(is_slow_r) begin
					if(slow_counter_r == 0) 	mode_addr = addr_r + 1;				// slow
				else							mode_addr = addr_r + 1 + speed_r;	// fast, normal
				end
			end
		end
	endcase
	if(mode_addr > i_sram_stop_addr)	addr_w = 0;
	else								addr_w = mode_addr;
end

// i_data: get current/next data
//		slow: get new data from SRAM every speed_r cycles
//		fast/normal: get new data from SRAM every cycle
always@(*) begin
	sram_data_w = sram_data_r;
	sram_data_next_w = sram_data_next_r;
	case(state_r)
		S_IDLE:		sram_data_next_w = 0;
		S_PAUSE:	sram_data_next_w = i_sram_data;
		S_GET: begin
			if(get_data_counter_r == 2) begin
				if(is_slow_r) begin			// slow
					if(slow_counter_r == 0) begin
						sram_data_w = sram_data_next_r;
						sram_data_next_w = i_sram_data;
					end
				end
				else begin					// fast/normal
					sram_data_w = sram_data_next_r;
					sram_data_next_w = i_sram_data;
				end
			end
		end
	endcase
end

// o_data:
//		slow mode 1: calculate linear interpolation of sram_data & sram_data_next
//		other modes: directly get from sram_data
reg signed [16:0] diff;
reg signed [20:0] diff_counter;
reg signed [20:0] diff_counter_div_speed;
always@(*) begin
	o_data_w = o_data_r
	diff = 0;
	diff_counter = 0;
	diff_counter_div_speed = 0;
	case(state_r)
		S_IDLE: o_data_w = 0;
		S_GET: begin
			if(get_data_counter_r == 3) begin
				if(is_slow_r) begin
					if(slow_mode_r) begin
						diff = $signed(sram_data_next) - $signed(sram_data);
						diff_counter = $signed(diff) * $signed({1'b0, slow_counter_r});
						diff_counter_div_speed = $signed($signed(diff_counter) / $signed({1'b0, speed_r + 1}));
						o_data_w = $signed($signed(sram_data) + $signed(diff_counter_div_speed))
					end
					else o_data_w = sram_data;
				end
				else o_data_w = sram_data;
			end
		end
	endcase
end

//alwaysff
always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state_r <= S_IDLE;
            is_pause_r <= 1;
			slow_counter_r <= 0;
			get_data_counter_r <= 0;
			addr_r <= 0;
			speed_r <= 0;
			o_data_r <= 0;
			is_slow_r <= 0;
			sram_data_r <= 0;
			sram_data_next_r <= 0;
			slow_mode_r <= 0;
        end
        else begin
            state_r <= state_w;
            is_pause_r <= is_pause_w;
			slow_counter_r <= slow_counter_w;
			get_data_counter_r <= get_data_counter_w;
			addr_r <= addr_w;
			speed_r <= speed_w;
			o_data_r <= o_data_w;
			is_slow_r <= is_slow_w;
			sram_data_r <= sram_data_w;
			sram_data_next_r <= sram_data_next_w;
			slow_mode_r <= slow_mode_w;
        end
    end

endmodule
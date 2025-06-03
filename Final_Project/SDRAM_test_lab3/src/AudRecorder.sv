/*
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(),
	.i_pause(),
	.i_stop(),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record), //[19:0]
	.o_data(data_record),    //[15:0]
);
*/

module AudRecorder (
    input i_rst_n,
    input i_clk,
    input i_lrc,    // mic only right channel, so only need to handle when i_lrc is high
    input i_start,  //錄音開始按鈕
    input i_pause,  //錄音暫停按鈕
    input i_stop,   //錄音停止按鈕
    input i_data,   // i2s data
    output [19:0] o_address, // total 2^20 words by 16 bits can be saved
    output [15:0] o_data,
    output o_valid,
    output [19:0] o_stop_address, // stop address
    output [6:0] o_state
);

//FSM & counter
localparam IDLE  = 7'b1111111;
localparam WAIT  = 7'b0000001; //LEFT
localparam RIGHT = 7'b0000010; //這裡輸入
localparam STORE = 7'b0000100;
localparam DONE  = 7'b0001000; 
localparam PAUSE = 7'b0010000;
localparam STOP  = 7'b0100000; // stop address


localparam COUNT = 4'd15;

logic [6:0] state_r, state_w;
logic [3:0] counter_r, counter_w;

//stop & pause
logic stop_r, stop_w;
logic pause_r, pause_w;

//output
logic [15:0] output_r, output_w;
logic [19:0] addr_r, addr_w;

assign o_address = addr_r;
assign o_data = output_r;
assign o_valid = (state_r == STORE) ? 1'b1 : 1'b0;
// assign o_stop_address = addr_r;
assign o_stop_address = 20'hfffff;

assign o_state = state_r;

//FSM
always_comb begin
    state_w = state_r;
    case (state_r)
        IDLE: begin
            if (i_start)  state_w = WAIT; 
        end
        WAIT: begin //LEFT
            if (stop_r)             state_w = STOP;
            else if (i_lrc)         state_w = RIGHT;
            else if (pause_r)       state_w = PAUSE;
            
        end
        RIGHT: begin //這裡傳訊號      
            if (counter_r == COUNT) state_w = STORE;
        end
        STORE: begin
            if (stop_r)             state_w = STOP;
            else if (pause_r)       state_w = PAUSE;                
            else if (!i_lrc)        state_w = WAIT;
            else                    state_w = DONE;
        end
        DONE: begin
            if (stop_r)             state_w = STOP;
            else if (pause_r)       state_w = PAUSE;                
            else if (!i_lrc)        state_w = WAIT;
        end
        PAUSE: begin
            if (i_start)            state_w = WAIT;
            else if (stop_r)        state_w = STOP;
        end
        STOP: begin
            state_w = IDLE;
        end
        default: begin
            state_w = state_r;
        end
    endcase
end

//counter
always_comb begin
    if (state_r == RIGHT && counter_r <= COUNT) begin
            counter_w = counter_r + 1'b1;
    end
    else if (state_r == PAUSE) begin
        counter_w = counter_r;
    end
    else begin
        counter_w = 4'b0000;
    end
end

//stop logic
always_comb begin
    if (i_stop)         stop_w = 1'b1;
    else if (i_start)   stop_w = 1'b0;
    else                stop_w = stop_r;
end

//pause logic
always_comb begin
    if (i_pause && state_r != PAUSE && state_r != IDLE) pause_w = 1'b1;
    else if (i_start && state_r == PAUSE)               pause_w = 1'b0; //進到WAIT
    else if (state_r == STOP)                           pause_w = 1'b0;
    else                                                pause_w = pause_r;
end

//address logic
always_comb begin
    if(state_r == IDLE && i_start)  addr_w = 20'b0;
    else if (state_r == STORE)      addr_w = addr_r + 1'b1;
    else                            addr_w = addr_r;
end

//output logic
always_comb begin
    if(state_r == RIGHT && counter_r <= COUNT) begin
        output_w = {output_r[14:0], i_data};
    end
    else begin 
        output_w = output_r;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= IDLE;
        counter_r <= 4'b0000;
        output_r <= 16'b0000000000000000;
        addr_r <= 20'b00000000000000000000;
        stop_r <= 1'b0;
        pause_r <= 1'b0;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        output_r <= output_w;
        addr_r <= addr_w;
        stop_r <= stop_w;
        pause_r <= pause_w;
    end
end
endmodule
module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    
    output  [4:0] avm_address,
    
    output        avm_read,
    input  [31:0] avm_readdata,
    
    output        avm_write,
    output [31:0] avm_writedata,
    
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_GET_KEY = 0;
localparam S_GET_DATA = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_SEND_DATA = 3;




logic [255:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;
logic [1:0] state_r, state_w;

logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [255:0] rsa_dec;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = dec_r[247-:8]; //等於dec_r[247:240]

Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec), //串
    .o_finished(rsa_finished) //串
);

task StartRead;//需要呼叫的一個模組!!!告訴avm_address我們要幹嘛
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

//===TODO=============================================================

// Logic Declaration
logic [7:0] rx_data, rx_data_next;
logic  rrdy, trdy, rrdy_next, trdy_next;

//wire assignment:這邊是Core的input，w,r會延後一個cycle
assign rsa_start_w = 
assign enc_w = 變數enc?
assign d_w = 變數d?
assign n_w = 變數N?

assign dec_w = dec_r的位移



//read data
assign rx_data_next = (rrdy && avm_waitrequest == 0)? avm_readdata[7:0] : rx_data;


always_comb begin

    
     = rsa_dec;
     = rsa_finished;
    
end

//FSM
always_comb begin
    //default
    state_w = state_r;

    if(avm_waitrequest == 0) begin
        case(state_r)
            S_GET_KEY: begin
                if (rrdy_next) begin
                    state_w = S_GET_DATA;
                end
                else if (trdy_next) begin
                    state_w = S_SEND_DATA;
                end
                else begin
                    state_w = S_GET_KEY;
                end
            end

            S_GET_DATA: begin
                if (bytes_counter_r == 63) begin
                    state_w = S_WAIT_CALCULATE;
                end 
                else if (rrdy == 1) begin

                    state_w = S_GET_KEY;
                end
            end
            S_WAIT_CALCULATE: begin
                if (rsa_finished) begin
                    StartWrite(TX_BASE);
                    state_w = S_SEND_DATA;
                end else begin
                    state_w = S_WAIT_CALCULATE;
                end
            end
            S_SEND_DATA: begin
                if (bytes_counter_r == 63) begin
                    StartWrite(TX_BASE);
                    state_w = S_SEND_DATA;
                end else begin
                    state_w = S_GET_KEY;
                end
            end
            default: state_w = S_GET_KEY;
        endcase
    end
end

//counters
always_comb begin
    // Default assignment for bytes_counter_w
    bytes_counter_w = bytes_counter_r;

    if(avm_waitrequest == 0) begin
        case(state_r)
            S_GET_KEY: begin
                bytes_counter_w = bytes_counter_r + 1;
            end
            S_GET_DATA: begin
                if (rrdy) begin
                    bytes_counter_w = bytes_counter_r + 1;
                end
            end
            S_SEND_DATA: begin
                if (trdy) begin
                    bytes_counter_w = bytes_counter_r + 1;
                end
            end
            // No need for default case now
        endcase                     
    end
end





//================================================================

always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        d_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_GET_KEY;
        bytes_counter_r <= 63;
        rsa_start_r <= 0;
    end else begin
        n_r <= n_w;
        d_r <= d_w;
        enc_r <= enc_w;
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;
    end
end

endmodule

`define DEFAULT_FRAME_H 640
`define DEFAULT_FRAME_V 480
`define DEFAULT_FRAME_RATE 60

module VGA_test#(
    parameter H_SIZE = `DEFAULT_FRAME_H, // 默認寬度
    parameter V_SIZE = `DEFAULT_FRAME_V, // 默認高度
    parameter FRAME_RATE = `DEFAULT_FRAME_RATE // 默認偵率
)(
    input i_VGA_clk,
    input i_rst_n,

    output o_VGA_SYNC_N , // VGA同步信號
    output o_VGA_BLANK_N, // VGA空白信號

    output o_VGA_HS, // VGA水平同步信號
    output o_VGA_VS, // VGA垂直同步信號

    output [7:0] o_VGA_R, // VGA紅色通道
    output [7:0] o_VGA_G, // VGA綠色通道
    output [7:0] o_VGA_B, // VGA藍色通道

);

// ---------- Local Parameters ---------- //

    // Dynamically select timing parameters at elaboration
    localparam H_A = 96;    //代表sync pulse
    localparam H_B = 48;    //代表back porch
    localparam H_D = 16;    //代表front porch    
    localparam V_A = 2;     //代表sync pulse
    localparam V_B = 33;    //代表back porch
    localparam V_D = 10;    //代表front porch
    
    //用來看H,V是在哪一階段
    parameter S_B = 0; // back porch
    parameter S_D = 2; // front porch
    parameter S_A = 3; // sync
    parameter S_C = 1; // active

    //TODO:初始化H,V的寬度
    parameter H_WIDTH = H_A + H_B + H_D; // 水平總寬度
    parameter V_WIDTH = V_A + V_B + V_D; // 垂直總高度


// ---------- Internal Signals ---------- //

    logic [23:0] RGB_r, RGB_w;
    
    logic [1:0] H_state_r, H_state_w; // 水平狀態
    logic [H_WIDTH-1:0] H_counter_r, H_counter_w; // 水平計數器
    logic H_sync_r, H_sync_w; // 水平同步信號

    
    logic [1:0] V_state_r, V_state_w; // 垂直狀態
    logic [V_WIDTH-1:0] V_counter_r, V_counter_w; // 垂直計數器
    logic V_sync_r, V_sync_w; // 垂直同步信號




// ---------- Wire Assignments ---------- //

	assign o_VGA_SYNC_N  = 1'b0; //預設值參考1482idiot
	assign o_VGA_BLANK_N = 1'b1; //預設值參考1482idiot

    assign o_VGA_HS = H_sync_r; 
    assign o_VGA_VS = V_sync_r; 
    
    
    assign o_VGA_R = RGB_r[23:16]; // 紅色通道
    assign o_VGA_G = RGB_r[15:8];  // 綠色通道
    assign o_VGA_B = RGB_r[7:0];   // 藍色通道



// ---------- Combinational Logic ---------- //

// RGB Logic
    always_comb begin
        RGB_w = 24'h000000; // 預設為黑色

        // 當處於活動區域時，設定RGB顏色
        if (H_state_r == S_ACTIVE && V_state_r == S_ACTIVE) begin
            RGB_w = 24'hFFFFFF; // 白色
        end
    end

// Horizontal state & counter
    always @(*) begin
        H_state_w = H_state_r;
        H_counter_w = H_counter_r + 1;
        H_sync_w = !(H_state_r == S_A);

        case (H_state_r)
            S_B: begin 
                if (H_counter_r == H_B) begin
                    H_state_w = S_C;
                    H_counter_w = 1;
                end
            end
            S_C: begin 
                if (H_counter_r == H_SIZE) begin
                    H_state_w = S_D;
                    H_counter_w = 1;
                end
            end
            S_D: begin 
                if (H_counter_r == H_D) begin
                    H_state_w = S_A;
                    H_counter_w = 1;
                end
            end
            S_A: begin 
                if (H_counter_r == H_A) begin
                    H_state_w = S_B;
                    H_counter_w = 1;
                end
            end
        endcase
    end

// Vertical state & counter
    always @(*) begin
        V_state_w = V_state_r;
        V_counter_w = V_counter_r;
        V_sync_w = !(V_state_r == S_A);

        if (H_state_r == S_A && H_counter_r == H_A) begin
            V_counter_w = V_counter_r + 1;
            case (V_state_r)
                S_B: begin 
                    if (V_counter_r == V_B) begin
                        V_state_w = S_C;
                        V_counter_w = 1;
                    end
                end
                S_C: begin 
                    if (V_counter_r == V_SIZE) begin
                        V_state_w = S_D;
                        V_counter_w = 1;
                    end
                end
                S_D: begin 
                    if (V_counter_r == V_D) begin
                        V_state_w = S_A;
                        V_counter_w = 1;
                    end
                end
                S_A: begin 
                    if (V_counter_r == V_A) begin
                        V_state_w = S_B;
                        V_counter_w = 1;
                    end
                end
            endcase
        end
    end

// ---------- Squential Logic ---------- //


endmodule
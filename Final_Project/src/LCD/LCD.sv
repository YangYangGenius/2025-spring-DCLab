module LCD (
    input clk,                    // 50MHz clock
    input rst,                    // Reset
    input [17:0] SW,              // Slide switches
    output LCD_ON,                // LCD power
    output LCD_BLON,              // LCD backlight
    output reg LCD_EN,
    output reg LCD_RS,
    output reg LCD_RW,
    output [7:0] LCD_DATA
);

assign LCD_ON = 1;
assign LCD_BLON = 1;

reg [7:0] LCD_DATA_r;
assign LCD_DATA = LCD_DATA_r;

reg [3:0] state;
reg [19:0] counter;
reg clk_buf;

reg [7:0] lcd_char;
reg [7:0] last_lcd_char;

parameter
    INIT      = 4'd0,
    FUNC      = 4'd1,
    DISPLAY   = 4'd2,
    ENTRY     = 4'd3,
    CLEAR     = 4'd4,
    CLEAR_WAIT= 4'd5,
    SET_ADDR  = 4'd6,
    WRITE     = 4'd7,
    WRITE_OFF = 4'd8,
    IDLE      = 4'd9;

// Clock divider ~1ms pulse
always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        clk_buf <= 0;
    end else begin
        if (counter >= 20'd49_9999) begin // 10ms (for reliable timing)
            counter <= 0;
            clk_buf <= 1;
        end else begin
            counter <= counter + 1;
            clk_buf <= 0;
        end
    end
end

// FSM logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= INIT;
        LCD_EN <= 0;
        LCD_RS <= 0;
        LCD_RW <= 0;
        LCD_DATA_r <= 8'd0;
        last_lcd_char <= 8'd0;
    end else if (clk_buf) begin
        case (state)
            INIT: begin
                LCD_RS <= 0;
                LCD_RW <= 0;
                LCD_DATA_r <= 8'h38; // Function Set
                LCD_EN <= 1;
                state <= FUNC;
            end
            FUNC: begin
                LCD_EN <= 0;
                state <= DISPLAY;
            end
            DISPLAY: begin
                LCD_RS <= 0;
                LCD_RW <= 0;
                LCD_DATA_r <= 8'h0C; // Display ON
                LCD_EN <= 1;
                state <= ENTRY;
            end
            ENTRY: begin
                LCD_EN <= 0;
                LCD_RS <= 0;
                LCD_RW <= 0;
                LCD_DATA_r <= 8'h06; // Entry mode set
                LCD_EN <= 1;
                state <= CLEAR;
            end
            CLEAR: begin
                LCD_EN <= 0;
                LCD_RS <= 0;
                LCD_RW <= 0;
                LCD_DATA_r <= 8'h01; // Clear display
                LCD_EN <= 1;
                state <= CLEAR_WAIT;
            end
            CLEAR_WAIT: begin
                LCD_EN <= 0;
                state <= SET_ADDR;
            end
            SET_ADDR: begin
                lcd_char <= (SW[12]) ? 8'h61 : 8'h62; // 'a' or 'b'
                LCD_RS <= 0;
                LCD_RW <= 0;
                LCD_DATA_r <= 8'h80; // Set cursor to address 0
                LCD_EN <= 1;
                state <= WRITE;
            end
            WRITE: begin
                LCD_EN <= 0;
                LCD_RS <= 1;
                LCD_RW <= 0;
                LCD_DATA_r <= lcd_char;
                LCD_EN <= 1;
                last_lcd_char <= lcd_char;
                state <= WRITE_OFF;
            end
            WRITE_OFF: begin
                LCD_EN <= 0;
                state <= IDLE;
            end
            IDLE: begin
                lcd_char <= (SW[12]) ? 8'h61 : 8'h62;
                if (lcd_char != last_lcd_char) begin
                    state <= SET_ADDR;
                end else begin
                    state <= IDLE;
                end
            end
            default: state <= INIT;
        endcase
    end
end

endmodule

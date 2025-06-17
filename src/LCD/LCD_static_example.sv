module LCD(  
    input clk, // Clock signal, 50MHz  
    input rst, // Reset signal, active low

    input [17:0] SW, // Slide switches

    output LCD_ON, // LCD power on/off control  
    output LCD_BLON,
    output LCD_EN, // LCD enable pin, executes command on 1->0 edge  
    output reg LCD_RS, // LCD data/command selection pin: data=1, command=0  
    output reg LCD_RW, // LCD write/read selection pin: write=0, read=1  
    output [7:0] LCD_DATA // LCD data bus
);

assign LCD_ON = 1; // Power on the LCD
assign LCD_BLON = 1; // Backlight on

reg [7:0] LCD_DATA_r;
assign LCD_DATA = LCD_DATA_r;

  
reg [8:0] count;  
reg clk_div1;       // 500 clock cycles, 20ns*500 = 10us  
reg clk_div2;       // 1000 clock cycles, 20us  
reg [7:0] count1;   // 250 clk_div2 cycles = 5ms  
reg clk_buf;  

// Frequency divider
always @(posedge clk or negedge rst) begin  
    if (!rst) begin  
        count <= 0;  
    end else begin  
        if (count < 250) begin  
            clk_div1 <= 0;  
            count <= count + 1'b1;  
        end else if (count >= 500 - 1) begin  
            count <= 0;  
        end else begin  
            clk_div1 <= 1;  
            count <= count + 1'b1;  
        end  
    end  
end  

always @(posedge clk_div1 or negedge rst) begin  
    if (!rst)  
        clk_div2 <= 0;  
    else  
        clk_div2 <= ~clk_div2;  
end  

always @(posedge clk_div2 or negedge rst) begin  
    if (!rst) begin  
        count1 <= 0;  
        clk_buf <= 0;  
    end else begin  
        if (count1 < 125) begin  
            clk_buf <= 0;  
            count1 <= count1 + 1'b1;  
        end else if (count1 >= 250 - 1) begin  
            count1 <= 0;  
        end else begin  
            clk_buf <= 1;  
            count1 <= count1 + 1'b1;  
        end  
    end  
end  

assign LCD_EN = clk_buf;  

// Display control module
reg [4:0] state;        
reg [5:0] address;      

parameter     
    IDLE           = 4'd0,  
    CLEAR          = 4'd1,  
    SET_FUNCTION   = 4'd2,  
    SWITCH_MODE    = 4'd3,  
    SET_MODE       = 4'd4,  
    SET_DDRAM1     = 4'd5,  
    WRITE_RAM1     = 4'd6,  
    SET_DDRAM2     = 4'd7,  
    WRITE_RAM2     = 4'd8,  
    SHIFT          = 4'd9,  
    STOP           = 4'd10;  

reg [7:0] Data_First [15:0];  
reg [7:0] Data_Second [15:0];  

initial begin  
    Data_First[0]  = " ";  
    Data_First[1]  = "W";  
    Data_First[2]  = "W";  
    Data_First[3]  = "W";  
    Data_First[4]  = ".";  
    Data_First[5]  = "N";  
    Data_First[6]  = "B";  
    Data_First[7]  = "U";  
    Data_First[8]  = ".";  
    Data_First[9]  = "E";  
    Data_First[10] = "D";  
    Data_First[11] = "U";  
    Data_First[12] = ".";  
    Data_First[13] = "C";  
    Data_First[14] = "N";  
    Data_First[15] = " ";  

    Data_Second[0]  = " ";  
    Data_Second[1]  = " ";  
    Data_Second[2]  = " ";  
    Data_Second[3]  = "X";  
    Data_Second[4]  = "I";  
    Data_Second[5]  = "N";  
    Data_Second[6]  = "-";  
    Data_Second[7]  = "X";  
    Data_Second[8]  = "I";  
    Data_Second[9]  = "-";  
    Data_Second[10] = "4";  
    Data_Second[11] = "1";  
    Data_Second[12] = "1";  
    Data_Second[13] = " ";  
    Data_Second[14] = " ";  
    Data_Second[15] = " ";  
end  

// State control
always @(posedge clk_buf or negedge rst) begin  
    if (!rst) begin  
        state <= IDLE;  
        address <= 6'd0;  
        LCD_DATA_r <= 8'b00000000;  
        LCD_RS <= 0;  
        LCD_RW <= 0;  
    end else begin  
        case (state)  
            IDLE: begin  
                LCD_DATA_r <= 8'bzzzzzzzz;  
                state <= CLEAR;  
            end  
            CLEAR: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'b00000001;  
                state <= SET_FUNCTION;  
            end  
            SET_FUNCTION: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'b00111100; // Function set: 8-bit, 2 lines, 5x10 dots  
                state <= SWITCH_MODE;  
            end  
            SWITCH_MODE: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'b00001111; // Display ON, cursor ON, blink ON  
                state <= SET_MODE;  
            end  
            SET_MODE: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'b00000110; // Entry mode set: increment cursor, no display shift  
                state <= SHIFT;  
            end  
            SHIFT: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'b00010100; // Cursor/display shift: shift display right  
                state <= SET_DDRAM1;  
            end  
            SET_DDRAM1: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'h80 + 8'd0; // Set DDRAM address to line 1, position 0  
                address <= 6'd0;  
                state <= WRITE_RAM1;  
            end  
            WRITE_RAM1: begin  
                if (address <= 15) begin  
                    LCD_RS <= 1;  
                    LCD_RW <= 0;  
                    LCD_DATA_r <= Data_First[address];  
                    address <= address + 1'b1;  
                    state <= WRITE_RAM1;  
                end else begin  
                    LCD_RS <= 0;  
                    LCD_RW <= 0;  
                    LCD_DATA_r <= 8'h80 + 8'd64; // Set DDRAM address to line 2, position 0  
                    address <= 6'd0;  
                    state <= WRITE_RAM2;  
                end  
            end  
            WRITE_RAM2: begin  
                if (address <= 15) begin  
                    LCD_RS <= 1;  
                    LCD_RW <= 0;  
                    LCD_DATA_r <= Data_Second[address];  
                    address <= address + 1'b1;  
                    state <= WRITE_RAM2;  
                end else begin  
                    state <= STOP;  
                end  
            end  
            STOP: begin  
                LCD_RS <= 0;  
                LCD_RW <= 0;  
                LCD_DATA_r <= 8'bzzzz_zzzz;  
                state <= STOP;  
            end  
            default: state <= IDLE;  
        endcase  
    end  
end  

endmodule

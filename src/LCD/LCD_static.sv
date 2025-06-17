module LCD(  
    input clk, // Clock signal, 50MHz  
    input rst, // Reset signal, active low

    input [17:0] SW, // Slide switches
    input [4:0] BtnID, // Push buttons
    input any_pos,
    input any_neg, // Any button pressed or released

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

reg [17:0] prev_SW;
reg [4:0] prev_BtnID;
wire refresh_display = (prev_SW != SW) || (prev_BtnID != BtnID); // Check if the switch state has changed

  
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

always @(posedge clk_buf or negedge rst) begin
    if (!rst) begin
        prev_SW <= 18'b0;
        prev_BtnID <= 5'b11111;
    end else begin
        prev_SW <= SW;
        prev_BtnID <= BtnID;
    end
end


localparam SWIDX_SYN = 7;
localparam SWIDX_REP = 9;
localparam SWIDX_SHAPE1 = 6;
localparam SWIDX_SHAPE0 = 5;
localparam SWIDX_VOL1 = 4;
localparam SWIDX_VOL0 = 3;
localparam SWIDX_OCT1 = 2;
localparam SWIDX_OCT0 = 1;

wire is_syn = SW[SWIDX_SYN];
wire is_rep = SW[SWIDX_REP];
wire [1:0] shape = {SW[SWIDX_SHAPE1], SW[SWIDX_SHAPE0]};
wire [1:0] vol = {SW[SWIDX_VOL1], SW[SWIDX_VOL0]};
wire [1:0] oct = {SW[SWIDX_OCT1], SW[SWIDX_OCT0]};


// Generate the display data based on switch states
always @(posedge refresh_display) begin
    if (is_syn) begin
        Data_First[0]  <= "S";
        Data_First[1]  <= "Y";
        Data_First[2]  <= "N";
        Data_First[3]  <= " ";
    end else begin
        Data_First[0]  <= "P";
        Data_First[1]  <= "E";
        Data_First[2]  <= "R";
        Data_First[3]  <= "C";
    end

    Data_First[4]  <= " ";

    if (is_rep) begin
        Data_First[5]  <= "R";
        Data_First[6]  <= "E";
        Data_First[7]  <= "P";
    end else begin
        Data_First[5]  <= " ";
        Data_First[6]  <= " ";
        Data_First[7]  <= " ";
    end

    Data_First[8]  <= " ";

    if (is_syn) begin
        case (BtnID)
            0: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "C";
                Data_First[15] <= "5" - oct;
            end
            1: begin
                Data_First[9] <= "C";
                Data_First[10] <= "#";
                Data_First[11] <= "5" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "D";
                Data_First[14] <= "b";
                Data_First[15] <= "5" - oct;
            end
            2: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "D";
                Data_First[15] <= "5" - oct;
            end
            3: begin
                Data_First[9] <= "D";
                Data_First[10] <= "#";
                Data_First[11] <= "5" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "E";
                Data_First[14] <= "b";
                Data_First[15] <= "5" - oct;
            end
            4: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "E";
                Data_First[15] <= "5" - oct;
            end
            5: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "F";
                Data_First[15] <= "5" - oct;
            end
            6: begin
                Data_First[9] <= "F";
                Data_First[10] <= "#";
                Data_First[11] <= "5" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "G";
                Data_First[14] <= "b";
                Data_First[15] <= "5" - oct;
            end
            7: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "G";
                Data_First[15] <= "5" - oct;
            end
            8: begin
                Data_First[9] <= "G";
                Data_First[10] <= "#";
                Data_First[11] <= "5" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "A";
                Data_First[14] <= "b";
                Data_First[15] <= "5" - oct;
            end
            9: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "A";
                Data_First[15] <= "5" - oct;
            end
            10: begin
                Data_First[9] <= "A";
                Data_First[10] <= "#";
                Data_First[11] <= "5" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "B";
                Data_First[14] <= "b";
                Data_First[15] <= "5" - oct;
            end
            11: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "B";
                Data_First[15] <= "5" - oct;
            end
            12: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "C";
                Data_First[15] <= "6" - oct;
            end
            13: begin
                Data_First[9] <= "C";
                Data_First[10] <= "#";
                Data_First[11] <= "6" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "D";
                Data_First[14] <= "b";
                Data_First[15] <= "6" - oct;
            end
            14: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "D";
                Data_First[15] <= "6" - oct;
            end
            15: begin
                Data_First[9] <= "D";
                Data_First[10] <= "#";
                Data_First[11] <= "6" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "E";
                Data_First[14] <= "b";
                Data_First[15] <= "6" - oct;
            end
            16: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "E";
                Data_First[15] <= "6" - oct;
            end
            17: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "F";
                Data_First[15] <= "6" - oct;
            end
            18: begin
                Data_First[9] <= "F";
                Data_First[10] <= "#";
                Data_First[11] <= "6" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "G";
                Data_First[14] <= "b";
                Data_First[15] <= "6" - oct;
            end
            19: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "G";
                Data_First[15] <= "6" - oct;
            end
            20: begin
                Data_First[9] <= "G";
                Data_First[10] <= "#";
                Data_First[11] <= "6" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "A";
                Data_First[14] <= "b";
                Data_First[15] <= "6" - oct;
            end
            21: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "A";
                Data_First[15] <= "6" - oct;
            end
            22: begin
                Data_First[9] <= "A";
                Data_First[10] <= "#";
                Data_First[11] <= "6" - oct;
                Data_First[12] <= "/";
                Data_First[13] <= "B";
                Data_First[14] <= "b";
                Data_First[15] <= "6" - oct;
            end
            23: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "B";
                Data_First[15] <= "6" - oct;
            end
            24: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= "C";
                Data_First[15] <= "7" - oct;
            end
            default: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= " ";
                Data_First[15] <= " ";
            end
        endcase
    end
    else begin
        case (BtnID)
            0: begin
                Data_First[9] <= "H";
                Data_First[10] <= "H";
                Data_First[11] <= "C";
                Data_First[12] <= "L";
                Data_First[13] <= "O";
                Data_First[14] <= "S";
                Data_First[15] <= "E";
            end
            1: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= "K";
                Data_First[13] <= "I";
                Data_First[14] <= "C";
                Data_First[15] <= "K";
            end
            3: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= "S";
                Data_First[12] <= "N";
                Data_First[13] <= "A";
                Data_First[14] <= "R";
                Data_First[15] <= "E";
            end
            5: begin
                Data_First[9] <= " ";
                Data_First[10] <= "H";
                Data_First[11] <= "H";
                Data_First[12] <= "O";
                Data_First[13] <= "P";
                Data_First[14] <= "E";
                Data_First[15] <= "N";
            end
            6: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= "C";
                Data_First[12] <= "R";
                Data_First[13] <= "A";
                Data_First[14] <= "S";
                Data_First[15] <= "H";
            end
            8: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= "T";
                Data_First[14] <= "O";
                Data_First[15] <= "M";
            end
            default: begin
                Data_First[9] <= " ";
                Data_First[10] <= " ";
                Data_First[11] <= " ";
                Data_First[12] <= " ";
                Data_First[13] <= " ";
                Data_First[14] <= " ";
                Data_First[15] <= " ";
            end
        endcase
    end

    if (!is_syn) begin
        Data_Second[0]  <= " ";
        Data_Second[1]  <= " ";
        Data_Second[2]  <= " ";
    end else if (shape == 2'b00) begin
        Data_Second[0]  <= "S";
        Data_Second[1]  <= "Q";
        Data_Second[2]  <= "R";
    end else if (shape == 2'b01) begin
        Data_Second[0]  <= "S";
        Data_Second[1]  <= "A";
        Data_Second[2]  <= "W";
    end else if (shape == 2'b10) begin
        Data_Second[0]  <= "T";
        Data_Second[1]  <= "R";
        Data_Second[2]  <= "I";
    end else begin  // shape == 2'b11
        Data_Second[0]  <= "S";
        Data_Second[1]  <= "I";
        Data_Second[2]  <= "N";
    end

    Data_Second[3]  <= " ";
    Data_Second[4]  <= "V";
    Data_Second[5]  <= "O";
    Data_Second[6]  <= "L";
    Data_Second[7]  <= "=";

    if (vol == 2'b00) begin
        Data_Second[8]  <= "4";
    end else if (vol == 2'b01) begin
        Data_Second[8]  <= "3";
    end else if (vol == 2'b10) begin
        Data_Second[8]  <= "2";
    end else begin  // vol == 2'b11
        Data_Second[8]  <= "1";
    end

    
    Data_Second[9]  <= " ";
    Data_Second[10] <= " ";
    
    if (!is_syn) begin
        Data_Second[11] <= " ";
        Data_Second[12] <= " ";
        Data_Second[13] <= " ";
        Data_Second[14] <= " ";
        Data_Second[15] <= " ";
    end else begin
        Data_Second[11] <= "C";
        Data_Second[12] <= "5" - oct; // C5, C4, C3, C2, when oct = 0, 1, 2, 3
        Data_Second[13] <= "~";
        Data_Second[14] <= "C";
        Data_Second[15] <= "7" - oct; // C7, C6, C5, C4, when oct = 0, 1, 2, 3
    end
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
                if (refresh_display) begin
                    state <= SET_DDRAM1;  // Go back to writing first line
                end else begin
                    state <= STOP;
                end  
            end  
            default: state <= IDLE;  
        endcase  
    end  
end  

endmodule

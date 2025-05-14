`timescale 1ns/1ps
`define CYCLE 10  // 1個 clock cycle 是 10ns（例如）
`define HCYCLE 5.0


module AudRecorder_tb;

// 宣告輸入角位（inputs to DUT）
    logic i_rst_n;     // Reset（active low）
    logic i_clk;       // Clock
    logic i_lrc;       // L/R clock，決定是左聲道還是右聲道
    logic i_start;     // 錄音開始按鈕
    logic i_pause;     // 錄音暫停按鈕
    logic i_stop;      // 錄音停止按鈕
    logic i_data;      // I2S 數據輸入

    logic [15:0] test_data [0:9];  // 宣告一個有 10 筆 16-bit 的 array
    logic [19:0] golden_addr [0:9];  // 存你預期的 address（0~9）



// 宣告輸出角位（outputs from DUT）
    logic [19:0] o_address; // 資料記憶體位址
    logic [15:0] o_data;    // 資料值（錄音內容）
    logic o_valid;          // 有效訊號：當資料準備好時會變成 1

// 實體化（instantiate）你寫的 AudRecorder 模組
    AudRecorder dut (
        .i_rst_n(i_rst_n),
        .i_clk(i_clk),
        .i_lrc(i_lrc),
        .i_start(i_start),
        .i_pause(i_pause),
        .i_stop(i_stop),
        .i_data(i_data),
        .o_address(o_address),
        .o_data(o_data),
        .o_valid(o_valid)
    );

// i_clk generation
    initial begin
        i_clk = 1'b1;
    end
    always begin
        #(`HCYCLE) i_clk = ~i_clk;
    end

task send_data_word;
    input [15:0] word;
    input stop;
    input pause;
    integer k;
    begin
        // ----------------------
        // 右聲道（i_lrc = 1）
        // ----------------------
        @(negedge i_clk); i_lrc = 1;   // 切換為右聲道
        @(negedge i_clk);             // 等 1 cycle 再開始送資料
        for (k = 15; k >= 8; k = k - 1) begin
            i_data = word[k];
            @(negedge i_clk);
        end
        i_stop = stop; 
        i_pause = pause; // 設定 stop 和 pause 的狀態
        for (k = 7; k >= 0; k = k - 1) begin
            i_data = word[k];
            @(negedge i_clk);
            i_stop = 0; 
            i_pause = 0; // 在這裡清除 stop 和 pause 的狀態
        end        

        // 等剩下的 cycle，總共滿 20 cycle
        repeat (2) @(negedge i_clk);  // 這裡已經過了 1（切換）+ 1（delay）+ 16（data）= 18 cycle
                                      // 所以還剩下 2 個 clock 要等
        // ----------------------
        // 左聲道（i_lrc = 0）
        // ----------------------
        @(negedge i_clk); i_lrc = 0;
        @(negedge i_clk);             // 等 1 cycle 再開始 dummy data
        for (k = 0; k < 16; k = k + 1) begin
            i_data = 1'bx; // 不重要的資料
            @(negedge i_clk);

        end

        repeat (2) @(negedge i_clk);  // 同樣補滿 20 cycle
    end
endtask


// 檢查資料是否正確的 task
    task check_output;
        input [15:0] expected_data;
        input [19:0] expected_address;
        begin
            @(posedge o_valid); // 等到 o_valid 為 1 的時候才檢查
            if (o_data !== expected_data) begin
                $display("[ERROR] o_data = %b, expected = %b", o_data, expected_data);
            end else if (o_address !== expected_address) begin
                $display("[ERROR] o_address = %d, expected = %d", o_address, expected_address);
            end else begin
                $display("[PASS] Output match: o_data = %b, o_address = %d", o_data, o_address);
            end
        end
    endtask


    integer i, j;

//主要測試
    initial begin
        // 所有訊號初始化
        i_rst_n  = 0; // 一開始先 reset
        i_lrc    = 0;
        i_start  = 0;
        i_pause  = 0;
        i_stop   = 0;
        i_data   = 0;

        // 保持 reset 一段時間，再釋放
        #(`CYCLE * 3); // 等待 2個時鐘週期
        i_rst_n  = 1;


        // 初始化測試資料（可以改成你想要的 pattern）
        test_data[0] = 16'b1010101010101010;
        test_data[1] = 16'b1111000011110000;
        test_data[2] = 16'b0000111100001111;
        test_data[3] = 16'b1100110011001100;
        test_data[4] = 16'b0011001100110011;
        test_data[5] = 16'b1111111100000000;
        test_data[6] = 16'b0000000011111111;
        test_data[7] = 16'b1000000000000001;
        test_data[8] = 16'b0111111111111110;
        test_data[9] = 16'b0101010101010101;
        // 初始化 address（你預期的 o_address 變化）
        for (i = 0; i < 10; i = i + 1) begin
            golden_addr[i] = i;  // golden_addr[0] = 0, [1] = 1, ..., [9] = 9
        end


        // 初始化錄音開始條件
        i_lrc = 0;      // 一開始是左聲道
        i_start = 1;    // 開始錄音
        i_pause = 0;
        i_stop = 0;
        #(`CYCLE * 1); // 等待 1個時鐘週期
        i_start = 0;
        #(`CYCLE * 19); // 等待 1個時鐘週期

        // 假裝每筆資料都在 i_lrc = 1 的時候餵
        for (i = 0; i < 3; i = i + 1) begin
            //$display("Sending data %d: %b", i, test_data[i]);
            send_data_word(test_data[i], 0, 0);
        end

        send_data_word(test_data[3], 0, 1); // 送第 4 筆資料
        i_start = 1;
        #(`CYCLE * 2); // 等待 2個時鐘週期



        for (i = 4; i < 10; i = i + 1) begin
            //$display("Sending data %d: %b", i, test_data[i]);
            send_data_word(test_data[i], 0, 0);
        end   

        $finish;
    end

    // 驗證輸出資料的 block
    initial begin
        integer idx;
        #(`CYCLE * 10); 
        for (idx = 0; idx < 10; idx = idx + 1) begin
            check_output(test_data[idx], golden_addr[idx]);  // 假設地址從 0 開始遞增
        end
        $display("[✔️ DONE] 所有資料驗證完成");
        
        $finish;
    end

    // Dumping waveform files
    initial begin
        $fsdbDumpfile("tb_AudRecorder.fsdb");
        $fsdbDumpvars;
    end
    initial #(`CYCLE*1000000) $finish;

endmodule

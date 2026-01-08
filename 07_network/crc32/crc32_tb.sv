//============================================================================
// File: crc32_tb.sv
// Description: CRC32のテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module crc32_tb;

    localparam int CLK_PERIOD = 10;
    localparam int TIMEOUT_CYCLES = 100;

    logic        clk;
    logic        rst_n;
    logic [7:0]  data_in;
    logic        valid_in;
    logic        sof;
    logic        eof;
    logic [31:0] crc_out;
    logic        crc_valid;

    int error_count = 0;
    int test_count = 0;

    // DUT
    crc32 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data_in   (data_in),
        .valid_in  (valid_in),
        .sof       (sof),
        .eof       (eof),
        .crc_out   (crc_out),
        .crc_valid (crc_valid)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシーケンス
    initial begin
        $dumpfile("crc32_tb.vcd");
        $dumpvars(0, crc32_tb);

        rst_n = 0;
        data_in = 0;
        valid_in = 0;
        sof = 0;
        eof = 0;

        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== CRC32 Test Start ===");

        // Test 1: "123456789" (標準テストベクター)
        test_count++;
        $display("\n[Test %0d] Standard test vector: \"123456789\"", test_count);
        send_frame_and_check(9, '{8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39}, 32'hCBF43926);

        // Test 2: 単一バイト
        test_count++;
        $display("\n[Test %0d] Single byte: 0x00", test_count);
        send_frame_and_check(1, '{8'h00}, 32'hD202EF8D);

        // Test 3: 2バイト
        test_count++;
        $display("\n[Test %0d] Two bytes: 0xFF 0xFF", test_count);
        send_frame_and_check(2, '{8'hFF, 8'hFF}, 32'hFFFFFFFF);

        // Test 4: 空フレーム（データなし）
        test_count++;
        $display("\n[Test %0d] Empty frame", test_count);
        send_frame_and_check(0, '{}, 32'hFFFFFFFF);

        // Test 5: 連続フレーム
        test_count++;
        $display("\n[Test %0d] Consecutive frames", test_count);
        send_frame_and_check(3, '{8'hAA, 8'hBB, 8'hCC}, 32'h898B52B6);
        send_frame_and_check(3, '{8'h11, 8'h22, 8'h33}, 32'h338E7D99);

        repeat(5) @(posedge clk);
        $display("\n=== CRC32 Test Complete ===");
        $display("Total tests: %0d", test_count);
        $display("Errors: %0d", error_count);
        if (error_count == 0) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end

    task send_frame_and_check(
        input int length,
        input logic [7:0] data[],
        input logic [31:0] expected_crc
    );
        logic [31:0] received_crc;
        int timeout;

        // フレーム送信
        if (length == 0) begin
            // 空フレーム
            @(posedge clk);
            sof = 1;
            eof = 1;
            valid_in = 0;
            @(posedge clk);
            sof = 0;
            eof = 0;
        end else begin
            // フレーム開始
            @(posedge clk);
            sof = 1;
            data_in = data[0];
            valid_in = 1;
            @(posedge clk);
            sof = 0;

            // データ送信
            for (int i = 1; i < length; i++) begin
                send_byte(data[i]);
            end

            // フレーム終了
            @(posedge clk);
            eof = 1;
            valid_in = 0;
            @(posedge clk);
            eof = 0;
        end

        // CRC出力待ち（タイムアウト付き）
        timeout = 0;
        while (!crc_valid && timeout < TIMEOUT_CYCLES) begin
            @(posedge clk);
            timeout++;
        end

        if (timeout >= TIMEOUT_CYCLES) begin
            $display("  [ERROR] Timeout waiting for crc_valid");
            error_count++;
        end else begin
            received_crc = crc_out;
            $display("  CRC32: 0x%08X (expected: 0x%08X)", received_crc, expected_crc);
            if (received_crc !== expected_crc) begin
                $display("  [ERROR] CRC mismatch!");
                error_count++;
            end else begin
                $display("  [OK]");
            end
        end

        // 次のテストのために少し待つ
        repeat(2) @(posedge clk);
    endtask

    task send_byte(input logic [7:0] byte_data);
        @(posedge clk);
        data_in = byte_data;
        valid_in = 1;
    endtask

endmodule

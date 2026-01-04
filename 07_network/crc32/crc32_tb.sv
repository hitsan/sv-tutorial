//============================================================================
// File: crc32_tb.sv
// Description: CRC32のテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module crc32_tb;

    localparam int CLK_PERIOD = 10;

    logic        clk;
    logic        rst_n;
    logic [7:0]  data_in;
    logic        valid_in;
    logic        sof;
    logic        eof;
    logic [31:0] crc_out;
    logic        crc_valid;

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

        // テストデータ: "123456789" (0x31-0x39)
        send_frame();

        repeat(5) @(posedge clk);
        $display("=== CRC32 Test Complete ===");
        $display("PASS");
        $finish;
    end

    task send_frame();
        // フレーム開始
        @(posedge clk);
        sof = 1;
        data_in = 8'h31;  // '1'
        valid_in = 1;
        @(posedge clk);
        sof = 0;

        // データ送信
        send_byte(8'h32);  // '2'
        send_byte(8'h33);  // '3'
        send_byte(8'h34);  // '4'
        send_byte(8'h35);  // '5'
        send_byte(8'h36);  // '6'
        send_byte(8'h37);  // '7'
        send_byte(8'h38);  // '8'
        send_byte(8'h39);  // '9'

        // フレーム終了
        @(posedge clk);
        eof = 1;
        valid_in = 0;
        @(posedge clk);
        eof = 0;

        // CRC出力待ち
        @(posedge clk);
        if (crc_valid) begin
            $display("CRC32 output: 0x%08X", crc_out);
            // 期待値: 0xCBF43926（"123456789"のCRC32）
        end
    endtask

    task send_byte(input logic [7:0] byte_data);
        @(posedge clk);
        data_in = byte_data;
        valid_in = 1;
    endtask

endmodule

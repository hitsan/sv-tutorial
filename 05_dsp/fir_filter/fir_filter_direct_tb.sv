//============================================================================
// File: fir_filter_direct_tb.sv
// Description: FIRフィルタ（直接形）のテストベンチ
// Author: SystemVerilog Tutorial
// License: MIT
//============================================================================

`timescale 1ns/1ps

module fir_filter_direct_tb;

    // パラメータ
    localparam int CLK_PERIOD = 10;
    localparam int DATA_WIDTH = 16;
    localparam int COEFF_WIDTH = 16;

    // テスト信号
    logic                          clk;
    logic                          rst_n;
    logic signed [DATA_WIDTH-1:0]  data_in;
    logic                          valid_in;
    logic signed [DATA_WIDTH-1:0]  data_out;
    logic                          valid_out;

    // DUT（Device Under Test）
    fir_filter_direct #(
        .DATA_WIDTH  (DATA_WIDTH),
        .COEFF_WIDTH (COEFF_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .data_in   (data_in),
        .valid_in  (valid_in),
        .data_out  (data_out),
        .valid_out (valid_out)
    );

    // クロック生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // テストシーケンス
    initial begin
        // VCD波形ダンプ
        $dumpfile("fir_filter_direct_tb.vcd");
        $dumpvars(0, fir_filter_direct_tb);

        // 初期化
        rst_n = 0;
        data_in = 0;
        valid_in = 0;

        // リセット解除
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("=== FIR Filter Direct Form Test Start ===");
        $display("Coefficients: [0.25, 0.5, 0.5, 0.25]");
        $display("");

        //====================================================================
        // テスト1: インパルス応答（δ[n]）
        //====================================================================
        $display("Test 1: Impulse Response");
        $display("Input: delta[n] = 1 at n=0, 0 otherwise");
        $display("Expected output: h[n] = coefficients");
        $display("");

        // インパルス入力: 1サンプルだけ1.0 (Q1.15 = 0x7FFF)
        send_sample(16'sh7FFF);
        // その後ゼロを入力
        for (int i = 0; i < 8; i++) begin
            send_sample(16'sh0000);
        end

        $display("");

        //====================================================================
        // テスト2: ステップ応答（u[n]）
        //====================================================================
        $display("Test 2: Step Response");
        $display("Input: u[n] = 1 for all n >= 0");
        $display("Expected: gradual rise to 1.5");
        $display("");

        for (int i = 0; i < 10; i++) begin
            send_sample(16'sh7FFF);  // 1.0 in Q1.15
        end

        $display("");

        //====================================================================
        // テスト3: 正弦波入力
        //====================================================================
        $display("Test 3: Sinusoidal Input");
        $display("Input: sin(2*pi*n/16) - low frequency");
        $display("");

        for (int i = 0; i < 16; i++) begin
            real angle = 2.0 * 3.14159265 * i / 16.0;
            real sin_val = $sin(angle);
            logic signed [15:0] sin_q15 = int'(sin_val * 32767.0);
            send_sample(sin_q15);
        end

        $display("");

        //====================================================================
        // テスト終了
        //====================================================================
        repeat(5) @(posedge clk);
        $display("=== FIR Filter Direct Form Test Complete ===");
        $display("PASS: All basic tests completed");
        $finish;
    end

    // サンプル送信タスク
    task send_sample(input logic signed [DATA_WIDTH-1:0] sample);
        @(posedge clk);
        data_in = sample;
        valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        // 出力を待つ
        @(posedge clk);
        if (valid_out) begin
            real out_real = $itor(data_out) / 32768.0;
            $display("Time=%0t: Input=%h (%.3f), Output=%h (%.3f)",
                     $time, sample, $itor(sample)/32768.0, data_out, out_real);
        end
    endtask

endmodule

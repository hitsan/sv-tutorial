// シフトレジスタのテストベンチ

`timescale 1ns / 100ps

module shift_register_tb;

  // クロックとリセット
  logic clk;
  logic rst_n;

  // テスト信号
  logic             serial_in;
  logic             serial_out;
  logic [7:0]       parallel_out;

  // パラメータ
  parameter int WIDTH = 8;
  parameter int CLK_PERIOD = 10;  // 10ns = 100MHz

  // DUT (Device Under Test)
  shift_register #(
      .WIDTH(WIDTH)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .serial_in(serial_in),
      .serial_out(serial_out),
      .parallel_out(parallel_out)
  );

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // テストシーケンス
  initial begin
    int errors = 0;

    $display("=================================================");
    $display("Shift Register Test");
    $display("=================================================");

    // 初期化
    rst_n = 0;
    serial_in = 0;

    // リセット解除
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // -----------------------------------------------------------------
    // テスト1: 基本的なシフト動作
    // -----------------------------------------------------------------
    $display("\n[Test 1] Basic Shift Operation");
    // TODO: テストケースを追加

    // -----------------------------------------------------------------
    // テスト結果サマリー
    // -----------------------------------------------------------------
    $display("\n=================================================");
    if (errors == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("TESTS FAILED with %0d errors", errors);
    end
    $display("=================================================");

    $finish;
  end

  // タイムアウト
  initial begin
    #10000;
    $display("TIMEOUT: Test took too long");
    $finish;
  end

endmodule

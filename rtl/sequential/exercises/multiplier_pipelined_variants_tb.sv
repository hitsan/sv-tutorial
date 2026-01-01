// パイプライン化された乗算器の各種実装 - テストベンチ
// 5つの異なるアーキテクチャを統合的にテスト
//
// TODO: このテストベンチを完成させて、5つの乗算器実装をテストしてください
//
// 要件:
// - 5つのDUTをインスタンス化
// - 共通のテストベクタで全バリアントをテスト
// - 各バリアントのレイテンシを考慮
// - 全バリアントが同じ結果を出力することを検証

`timescale 1ns / 100ps

module multiplier_pipelined_variants_tb;

  // テストパラメータ
  parameter int INPUT_WIDTH = 8;
  parameter int OUTPUT_WIDTH = INPUT_WIDTH * 2;
  parameter int CLK_PERIOD = 10;

  // TODO: 各実装のレイテンシを定義
  // localparam int LATENCY_MULTISTAGE = ?;
  // localparam int LATENCY_BOOTH = ?;
  // localparam int LATENCY_WALLACE = ?;
  // localparam int LATENCY_ARRAY = ?;
  // localparam int LATENCY_CSA = ?;
  // localparam int MAX_LATENCY = ?;

  // 共通信号
  logic                    clk;
  logic                    rst_n;
  logic [INPUT_WIDTH-1:0]  in0;
  logic [INPUT_WIDTH-1:0]  in1;

  // TODO: 各DUTの出力信号を定義
  // logic [OUTPUT_WIDTH-1:0] product_multistage;
  // logic [OUTPUT_WIDTH-1:0] product_booth;
  // logic [OUTPUT_WIDTH-1:0] product_wallace;
  // logic [OUTPUT_WIDTH-1:0] product_array;
  // logic [OUTPUT_WIDTH-1:0] product_csa;

  // TODO: エラーカウント変数を定義
  // int errors_multistage = 0;
  // ...

  // TODO: 5つのDUTをインスタンス化
  //
  // 例:
  // multiplier_pipelined_multistage #(
  //     .INPUT_WIDTH(INPUT_WIDTH),
  //     .NUM_STAGES (3)
  // ) dut_multistage (
  //     .clk    (clk),
  //     .rst_n  (rst_n),
  //     .in0    (in0),
  //     .in1    (in1),
  //     .product(product_multistage)
  // );
  //
  // multiplier_pipelined_booth #(
  //     .INPUT_WIDTH(INPUT_WIDTH),
  //     .IS_SIGNED  (1'b1)  // Boothはsignedに最適
  // ) dut_booth (
  //     .clk    (clk),
  //     .rst_n  (rst_n),
  //     .in0    (in0),
  //     .in1    (in1),
  //     .product(product_booth)
  // );
  //
  // 他の3つのDUTも同様にインスタンス化してください
  // 注: Booth以外はunsigned乗算のみでOK

  // クロック生成
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // テストシーケンス
  initial begin
    $display("=================================================");
    $display("Pipelined Multiplier Variants Test");
    $display("=================================================\n");

    // 初期化
    rst_n = 0;
    in0 = 0;
    in1 = 0;

    // リセット解除
    #(CLK_PERIOD * 2);
    rst_n = 1;
    #(CLK_PERIOD);

    // TODO: テストケースを実装
    //
    // 推奨テストケース:
    // 1. 基本テスト: 5×3, 0×100, 42×1, 1×255
    // 2. 境界値: 255×255, べき乗 (2×2, 4×4, 8×8, 16×16)
    // 3. パターン: 0x55×0xAA, 0xFF×0x01, 0x0F×0xF0
    // 4. ランダム: 30回程度

    // テストケース実行の例:
    // test_case(8'd5, 8'd3, "5 × 3");

    // TODO: 結果サマリーを表示
    // - 各バリアントのエラー数
    // - 全体の成功/失敗

    $finish;
  end

  // タイムアウト保護
  initial begin
    #100000;
    $display("TIMEOUT!");
    $finish;
  end

  // TODO: test_case タスクを実装
  //
  // 機能:
  // - 入力値 a, b を各DUTに供給
  // - 期待値 (a * b) を計算
  // - MAX_LATENCY 待機
  // - 各DUTの出力を検証
  // - クロスチェック: 全DUTの結果が一致することを確認
  //
  // task test_case(
  //     input logic [INPUT_WIDTH-1:0] a,
  //     input logic [INPUT_WIDTH-1:0] b,
  //     input string description
  // );
  //   // 実装してください
  // endtask

endmodule

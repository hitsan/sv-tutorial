// パイプライン化された乗算器の各種実装 - テストベンチ
// 2つの異なるアーキテクチャを統合的にテスト
//
// テスト内容:
// - Multi-Stage Pipeline (3段) とArray Multiplier (8段)
// - 共通のテストベクタで全バリアントをテスト
// - 各バリアントのレイテンシを考慮
// - 全バリアントが同じ結果を出力することを検証

`timescale 1ns / 100ps

module multiplier_pipelined_variants_tb;

  // テストパラメータ
  parameter int INPUT_WIDTH = 8;
  parameter int OUTPUT_WIDTH = INPUT_WIDTH * 2;
  parameter int CLK_PERIOD = 10;

  // 各実装のレイテンシを定義
  localparam int LATENCY_MULTISTAGE = 3;
  localparam int LATENCY_ARRAY = 8;
  localparam int MAX_LATENCY = 8;

  // 共通信号
  logic                    clk;
  logic                    rst_n;
  logic [INPUT_WIDTH-1:0]  in0;
  logic [INPUT_WIDTH-1:0]  in1;

  // 各DUTの出力信号を定義
  logic [OUTPUT_WIDTH-1:0] product_multistage;
  logic [OUTPUT_WIDTH-1:0] product_array;

  // エラーカウント変数を定義
  int errors_multistage = 0;
  int errors_array = 0;

  // 2つのDUTをインスタンス化
  multiplier_pipelined_multistage #(
      .INPUT_WIDTH(INPUT_WIDTH)
  ) dut_multistage (
      .clk    (clk),
      .rst_n  (rst_n),
      .in0    (in0),
      .in1    (in1),
      .product(product_multistage)
  );

  multiplier_pipelined_array #(
      .INPUT_WIDTH(INPUT_WIDTH)
  ) dut_array (
      .clk    (clk),
      .rst_n  (rst_n),
      .in0    (in0),
      .in1    (in1),
      .product(product_array)
  );

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

    // 基本テスト
    $display("\n[Test 1] Basic tests");
    test_case(8'd5, 8'd3, "5 × 3");
    test_case(8'd0, 8'd100, "0 × 100");
    test_case(8'd42, 8'd1, "42 × 1");
    test_case(8'd1, 8'd255, "1 × 255");

    // 境界値テスト
    $display("\n[Test 2] Boundary tests");
    test_case(8'd255, 8'd255, "255 × 255");
    test_case(8'd2, 8'd2, "2 × 2");
    test_case(8'd4, 8'd4, "4 × 4");
    test_case(8'd8, 8'd8, "8 × 8");
    test_case(8'd16, 8'd16, "16 × 16");

    // パターンテスト
    $display("\n[Test 3] Pattern tests");
    test_case(8'h55, 8'hAA, "0x55 × 0xAA");
    test_case(8'hFF, 8'h01, "0xFF × 0x01");
    test_case(8'h0F, 8'hF0, "0x0F × 0xF0");

    // ランダムテスト
    $display("\n[Test 4] Random tests");
    for (int i = 0; i < 30; i++) begin
      automatic logic [INPUT_WIDTH-1:0] a = INPUT_WIDTH'($urandom);
      automatic logic [INPUT_WIDTH-1:0] b = INPUT_WIDTH'($urandom);
      test_case(a, b, $sformatf("Random %0d: %0d × %0d", i, a, b));
    end

    // 結果サマリーを表示
    $display("\n=================================================");
    $display("Test Summary");
    $display("=================================================");
    $display("Multi-Stage errors: %0d", errors_multistage);
    $display("Array errors:       %0d", errors_array);
    $display("-------------------------------------------------");
    if (errors_multistage == 0 && errors_array == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("TESTS FAILED!");
    end
    $display("=================================================\n");

    $finish;
  end

  // タイムアウト保護
  initial begin
    #100000;
    $display("TIMEOUT!");
    $finish;
  end

  // test_case タスク
  task test_case(
      input logic [INPUT_WIDTH-1:0] a,
      input logic [INPUT_WIDTH-1:0] b,
      input string description
  );
    logic [OUTPUT_WIDTH-1:0] expected;

    // 期待値を計算
    expected = a * b;

    // 入力を設定
    in0 = a;
    in1 = b;

    // MAX_LATENCY待機（全パイプラインステージを通過）
    #(CLK_PERIOD * MAX_LATENCY);

    // Multi-Stage の検証
    if (product_multistage !== expected) begin
      $error("[%0t] Multi-Stage FAILED: %s = %0d (expected %0d)",
             $time, description, product_multistage, expected);
      errors_multistage++;
    end else begin
      $display("[%0t] Multi-Stage PASSED: %s = %0d",
               $time, description, product_multistage);
    end

    // Array の検証
    if (product_array !== expected) begin
      $error("[%0t] Array FAILED: %s = %0d (expected %0d)",
             $time, description, product_array, expected);
      errors_array++;
    end else begin
      $display("[%0t] Array PASSED: %s = %0d",
               $time, description, product_array);
    end

    // クロスチェック: 両方の実装が一致するか
    if (product_multistage !== product_array) begin
      $error("[%0t] CROSS-CHECK FAILED: %s - Multi-Stage=%0d, Array=%0d",
             $time, description, product_multistage, product_array);
    end

    // 次のテストのために1サイクル待機
    #(CLK_PERIOD);
  endtask

endmodule

// priority_encoder のテストベンチ
// パラメータ化されたpriority encoderを複数のサイズでテスト

`timescale 1ns / 100ps

module priority_encoder_tb;

  // ============================================================================
  // パラメータ
  // ============================================================================
  localparam int NUM_INPUTS = 8;  // テストする入力数（変更可能）
  localparam int NUM_OUTPUTS = $clog2(NUM_INPUTS);

  // ============================================================================
  // テストベンチの信号宣言
  // ============================================================================
  logic [NUM_INPUTS-1:0] inputs;
  logic [NUM_OUTPUTS-1:0] result;
  logic valid;

  // ============================================================================
  // DUT (Device Under Test) のインスタンス化
  // ============================================================================
  priority_encoder #(.NUM_INPUTS(NUM_INPUTS)) DUT (.*);

  // ============================================================================
  // Golden Reference関数
  // ============================================================================
  // DUTの期待値を計算する関数
  // 最上位ビットから優先的にエンコード（forループは最後に見つかった'1'を返す）
  function automatic logic [NUM_OUTPUTS-1:0] calc_expected_result(logic [NUM_INPUTS-1:0] din);
    logic [NUM_OUTPUTS-1:0] result_tmp;
    result_tmp = '0;
    for (int i = 0; i < NUM_INPUTS; i++) begin
      if (din[i]) result_tmp = i[NUM_OUTPUTS-1:0];
    end
    return result_tmp;
  endfunction

  // valid信号の期待値を計算する関数
  // 入力に少なくとも1つの'1'があればvalid=1
  function automatic logic calc_expected_valid(logic [NUM_INPUTS-1:0] din);
    return (din != '0);  // 全て0でなければvalid
  endfunction

  // ============================================================================
  // テストケース実行タスク
  // ============================================================================
  task automatic test_case(input logic [NUM_INPUTS-1:0] din);
    logic [NUM_OUTPUTS-1:0] expected_result;
    logic expected_valid;

    // 入力を設定
    inputs = din;

    // 組み合わせ回路なので伝搬遅延を考慮
    #1;

    // 期待値を計算
    expected_result = calc_expected_result(din);
    expected_valid  = calc_expected_valid(din);

    // result が期待値と一致することを確認（===でX/Z値も厳密にチェック）
    assert (result === expected_result)
    else
      $error("[%0t] inputs=%b: result=%0d expected=%0d", $realtime, din, result, expected_result);

    // valid が期待値と一致することを確認
    assert (valid === expected_valid)
    else $error("[%0t] inputs=%b: valid=%b expected=%b", $realtime, din, valid, expected_valid);

    #1;  // 次のテストケースまで待機
  endtask

  // ============================================================================
  // テストシーケンス
  // ============================================================================
  initial begin
    // 時刻フォーマット設定
    $timeformat(-9, 0, " ns");

    // テスト開始メッセージ
    $display("=================================================");
    $display("Priority Encoder %0d-input Test", NUM_INPUTS);
    $display("=================================================");

    // 全パターンをテスト（2^NUM_INPUTS パターン）
    // NUM_INPUTS が大きい場合は時間がかかるので注意
    for (int i = 0; i < (1 << NUM_INPUTS); i++) begin
      test_case(i[NUM_INPUTS-1:0]);
    end

    // テスト終了
    $display("=================================================");
    $display("Tests completed. %0d patterns tested.", 1 << NUM_INPUTS);
    $display("=================================================");
    $finish;
  end

  // ============================================================================
  // タイムアウト保護
  // ============================================================================
  initial begin
    #100000;  // 最大シミュレーション時間
    $display("ERROR: Simulation timeout!");
    $finish;
  end

endmodule : priority_encoder_tb


// ============================================================================
// テストベンチ設計のポイント
// ============================================================================
// 1. パラメータ NUM_INPUTS でテストサイズを変更可能
// 2. Golden reference関数で期待値を自動計算
//    - forループの動作に合わせて最下位ビットから優先
// 3. 全2^NUM_INPUTS パターンを網羅的にテスト
// 4. assertを使って自動的にエラーを検出
// 5. === 演算子でX/Z値も厳密にチェック
// 6. タイムアウト保護でハングを防ぐ
//
// 注意事項:
// - NUM_INPUTS が大きいとテスト時間が指数的に増加
//   (例: 16入力 = 65536パターン)
// - 大きな入力数の場合はランダムテストなどに変更を検討

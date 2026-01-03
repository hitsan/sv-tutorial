// 順序回路の合成例
// examples/register.svを参考に、以下の順序回路を実装してください

`timescale 1ns / 100ps

// ============================================================================
// 演習1: 基本的なD型フリップフロップ（非同期リセット）
// ============================================================================
// 要件:
// - クロックの立ち上がりエッジでdを取り込む
// - rst_nが0になると即座にqを0にクリア（非同期）
// - ノンブロッキング代入を使用
module exercise1_dff #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else q <= d;
  end
endmodule : exercise1_dff


// ============================================================================
// 演習2: イネーブル付きレジスタ
// ============================================================================
// 要件:
// - enが1のときのみdを取り込む
// - enが0のときは前の値を保持
// - 非同期リセット付き
module exercise2_enable_reg #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  // TODO: イネーブル制御を実装
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= '0;
    else if (en) q <= d;
  end

endmodule : exercise2_enable_reg


// ============================================================================
// 演習3: 2段パイプラインレジスタ
// ============================================================================
// 要件:
// - 入力dを2クロック遅延させる
// - stage1 -> stage2 -> qという構成
// - 各段でノンブロッキング代入を使用
module exercise3_pipeline #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  // TODO: 中間段のレジスタを宣言
  // TODO: パイプライン処理を実装
  logic [WIDTH-1:0] stage1;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= '0;
      stage1 <= '0;
    end else begin
      stage1 <= d;
      q <= stage1;
    end
  end

endmodule : exercise3_pipeline


// ============================================================================
// 演習4: アップカウンタ
// ============================================================================
// 要件:
// - クロックごとにカウント値を1増加
// - 最大値(2^WIDTH-1)に達したら0に戻る
// - リセット時は0にクリア
module exercise4_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    else if (count == '1) begin
      count <= '0;
    end else count <= count + 1;
  end

endmodule : exercise4_counter


// ============================================================================
// 演習5: イネーブル付きアップ/ダウンカウンタ
// ============================================================================
// 要件:
// - enが1のときのみカウント
// - upが1ならカウントアップ、0ならカウントダウン
// - オーバーフロー/アンダーフローで折り返し
module exercise5_updown_counter #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             up,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) count <= '0;
    else if (en) begin
      if (up) count <= count + 1;
      else count <= count - 1;
    end
  end
endmodule : exercise5_updown_counter


// ============================================================================
// よくある間違いの確認
// ============================================================================
// 以下を実装して、合成結果を確認してください:
//
// 間違い例1: always_ffでブロッキング代入を使う
// - 意図した動作になるか確認
// - シミュレーションと合成結果の違いに注意
//
// 間違い例2: always_combでノンブロッキング代入を使う
// - エラーまたは警告が出るか確認
//
// 間違い例3: 意図しないラッチの生成
// - 条件分岐で全ケースをカバーしない
// - 組み合わせ回路のつもりがラッチになる


// ============================================================================
// テストベンチ（オプション）
// ============================================================================
// 上記のモジュールをテストするテストベンチを作成してみてください
// - 各演習モジュールをインスタンス化
// - クロックとリセットを生成
// - 期待通りの動作をするか確認

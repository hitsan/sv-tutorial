// パイプライン化された乗算器の各種実装
// 様々なアーキテクチャのパイプライン乗算器を学習するための実装集
//
// このファイルには2つの異なるパイプラインアーキテクチャが含まれています:
// 1. Multi-Stage Pipeline: 基本的な3ステージパイプライン
// 2. Array Multiplier: シストリックアレイ構造

`timescale 1ns / 100ps

// ============================================================================
// 例1: Multi-Stage Pipeline (3ステージ)
// ============================================================================
// 要件:
// - 基本的な2ステージパイプラインを3ステージに拡張
// - 各ステージでバランスよく処理を分散
//
// 学習ポイント:
// - パイプラインステージ数とレイテンシの関係
// - ステージ数を増やすことでクリティカルパスを短縮
// - レイテンシは増加するがスループットは維持
//
// パイプライン構成:
// - Stage 1: 入力レジスタ (in0_r, in1_r)
// - Stage 2: 乗算レジスタ (mul_r)
// - Stage 3: 出力レジスタ (product)
//
module multiplier_pipelined_multistage #(
    parameter int INPUT_WIDTH = 8,
    localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic [INPUT_WIDTH-1:0]   in0,
    input  logic [INPUT_WIDTH-1:0]   in1,
    output logic [OUTPUT_WIDTH-1:0]  product
);
  logic [INPUT_WIDTH-1:0] in0_r;
  logic [INPUT_WIDTH-1:0] in1_r;
  logic [OUTPUT_WIDTH-1:0] mul_r;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      in0_r <= '0;
      in1_r <= '0;
      product <= '0;
    end else begin
      in0_r <= in0;
      in1_r <= in1;
      mul_r <= in0_r * in1_r;
      product <= mul_r;
    end
  end
endmodule : multiplier_pipelined_multistage


// ============================================================================
// 例2: Array Multiplier Pipeline
// ============================================================================
// 要件:
// - シストリックアレイ構造の乗算器
// - 各行が1パイプラインステージ
// - 規則的で理解しやすい構造
//
// アレイ乗算器:
// - 8x8の2次元配列構造（概念的）
// - 各行: 部分積を生成し、前の行の結果に加算
// - 行ごとにパイプラインレジスタを配置
//
// 学習ポイント:
// - シストリックアレイアーキテクチャ
// - 規則的な構造の利点（設計・検証が容易）
// - 空間パイプライン vs 時間パイプライン
// - レイテンシは長いが、構造が単純
//
module multiplier_pipelined_array #(
    parameter int INPUT_WIDTH = 8,
    localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic [INPUT_WIDTH-1:0]   in0,
    input  logic [INPUT_WIDTH-1:0]   in1,
    output logic [OUTPUT_WIDTH-1:0]  product
);
  logic [OUTPUT_WIDTH-1:0] sum[INPUT_WIDTH];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < INPUT_WIDTH; i++) begin
        sum[i] <= '0;
      end
      product <= '0;
    end 
    else begin
      sum[0] <= OUTPUT_WIDTH'(in0) & {OUTPUT_WIDTH{in1[0]}};
      for (int i = 1; i < INPUT_WIDTH; i++) begin
        sum[i] <= sum[i-1] + ((OUTPUT_WIDTH'(in0) & {OUTPUT_WIDTH{in1[i]}}) << i);
      end
      product <= sum[INPUT_WIDTH-1];
    end
  end
endmodule : multiplier_pipelined_array

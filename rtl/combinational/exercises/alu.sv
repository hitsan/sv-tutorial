// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

// ALU (Arithmetic Logic Unit)
// - 算術演算、論理演算、シフト演算、比較演算をサポートする汎用演算器
// - opcodeで演算を選択し、2つの入力オペランドに対して演算を実行
// - 結果とともにステータスフラグ（zero, overflow, negative）を出力

module alu #(
  parameter int WIDTH = 32
) (
  input logic [WIDTH-1:0] in0,
  input logic [WIDTH-1:0] in1,
  input logic [3:0] opcode,
  output logic [WIDTH-1:0] result,
  output logic zero,
  output logic overflow,
  output logic negative
);

  // TODO: 演算コードの定義
  // - 加算、減算
  // - 論理演算（AND, OR, XOR）
  // - シフト演算（左シフト、右論理シフト、右算術シフト）
  // - 比較演算（signed/unsigned）

  // TODO: opcodeに応じた演算の実装

  // TODO: ステータスフラグの計算
  // - zero: 結果がゼロかどうか
  // - overflow: 加算/減算でのオーバーフロー
  // - negative: 結果の符号

endmodule

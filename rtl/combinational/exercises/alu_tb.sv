// Greg Stitt
// University of Florida

`timescale 1ns / 100ps

module alu_tb;

  parameter int WIDTH = 32;
  parameter int NUM_TESTS = 1000;

  // TODO: 信号の宣言
  // - in0, in1: 入力オペランド
  // - opcode: 演算コード
  // - result: 演算結果
  // - zero, overflow, negative: ステータスフラグ

  // TODO: DUT（Design Under Test）のインスタンス化

  // TODO: テストシーケンス
  // - 各演算コードに対してランダムテストを実行
  // - 期待値と実際の結果を比較
  // - エラーがあれば $error で報告
  // - すべてのテストが完了したら $finish

endmodule
